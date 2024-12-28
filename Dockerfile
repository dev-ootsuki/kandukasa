# syntax = docker/dockerfile:1
#############################################################
# base image postgresql (17)
# install rbenv and path rbenv/bin (ruby, gem, bundler...etc)
#############################################################
ARG PG_VERSION=17.2
ARG STAGE_BASE="nuxt"
FROM docker.io/library/postgres:${PG_VERSION}-bullseye AS ruby
LABEL maintainer="dev-ootsuki"
ARG RUBY_VERSION=3.3.6
ARG APP_ENV="production"
ENV LANG="C.UTF-8"

# // TODO timezone

# install package (base & needed to application)
RUN apt-get update && \
    apt-get install -y --no-install-recommends libgdbm-dev libreadline-dev wget autoconf git zlib1g-dev libssl-dev build-essential \
	ca-certificates libffi-dev libyaml-dev libmariadb-dev libsqlite3-dev libpq-dev curl && \
    rm -rf /var/lib/apt/lists/*

# install rbenv
ENV RBENV_PATH="/usr/local/rbenv"
ENV RC_APPEND_PATH="/etc/profile.d/rbenv.sh"
ENV PATH=$RBENV_PATH/bin:$PATH
RUN GIT_SSL_NO_VERIFY=1 git clone https://github.com/rbenv/rbenv.git $RBENV_PATH && \
    echo 'eval "$(rbenv init -)"' >> $RC_APPEND_PATH && \
    GIT_SSL_NO_VERIFY=1 git clone https://github.com/rbenv/ruby-build.git $RBENV_PATH/plugins/ruby-build && \
    $RBENV_PATH/plugins/ruby-build/install.sh

# install ruby
ENV RUBY_VERSION=$RUBY_VERSION
RUN HOME=$RBENV_PATH rbenv install $RUBY_VERSION && \
    HOME=$RBENV_PATH rbenv global $RUBY_VERSION && \
    HOME=$RBENV_PATH rbenv rehash
ENV PATH=$RBENV_PATH/.rbenv/versions/$RUBY_VERSION/bin:$PATH

CMD [ "irb" ]


#############################################################
# rails image
# install project depends on gems
#############################################################
FROM ruby AS rails
ARG MASTER_KEY=""
ARG RAILS_ENV=$APP_ENV
ARG BUNDLE_DEPLOYMENT="1"
ARG BUNDLE_WITHOUT="development:test"
ENV RAILS_MASTER_KEY=$MASTER_KEY
# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libjemalloc2 libvips && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set environment
ENV RAILS_ENV=$APP_ENV
ENV BUNDLE_DEPLOYMENT=$BUNDLE_DEPLOYMENT
ENV BUNDLE_PATH="$RBENV_PATH/.rbenv/versions/$RUBY_VERSION/bundle"
ENV BUNDLE_WITHOUT=$BUNDLE_WITHOUT
ENV BACKEND_PATH="/app/backend"

# copy Gemfile and bundle install
COPY ./backend/Gemfile ./backend/Gemfile.lock $BACKEND_PATH/
WORKDIR $BACKEND_PATH
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git
COPY ./backend $BACKEND_PATH
#RUN bundle exec bootsnap precompile --gemfile


#############################################################
# nuxt image
# install nvm(contains npm,npx), yarn, nuxi
#############################################################
FROM rails AS nuxt
ENV NVM_VERSION="v0.40.1"
ENV NVM_DIR="/usr/local/nvm"
ENV FRONTEND_PATH="/app/frontend"
WORKDIR $NVM_DIR
# install nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash
# install yarn, nuxi
RUN . $NVM_DIR/nvm.sh && \
    nvm i --lts && \
    nvm use --lts && \ 
    npm i -g yarn && \ 
    npm i -g nuxi && \
	npm i -g npm-check-updates
# copy package.json and install
COPY ./frontend/package.json ./frontend/yarn.lock $FRONTEND_PATH/
WORKDIR $FRONTEND_PATH
RUN . $NVM_DIR/nvm.sh && \
    yarn install && \
    yarn postinstall
COPY ./frontend $FRONTEND_PATH
# genearate SPA
RUN . $NVM_DIR/nvm.sh && yarn generate

#############################################################
# DEVELOPMENT SETTINGS 
#############################################################
RUN groupadd --system --gid 4000 nuxt && \
    useradd nuxt --uid 4000 --gid 4000 --create-home --shell /bin/bash

RUN echo export NVM_DIR=$MVN_DIR >> /home/nuxt/.bashrc && \
    echo "#!/bin/bash" >> /etc/profile.d/nvm.sh && \ 
    echo  "$NVM_DIR/nvm.sh" >> /etc/profile.d/nvm.sh && \
    echo "source /etc/profile" >> /home/nuxt/.bashrc

# debugging
RUN apt-get update && apt-get install -y procps vim
# ruby debugger
EXPOSE 12345 
# rails port
EXPOSE 3000
# rails test
WORKDIR $BACKEND_PATH
RUN bundle install

#############################################################
# final stage
# install & settings server software
#############################################################
FROM $STAGE_BASE AS server

ARG DOMAIN_NAME="localhost"
# install server software
RUN apt-get update -qq && apt-get install -y nginx supervisor sudo && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# copy file of rails project
ENV BUNDLE_PATH="$RBENV_PATH/.rbenv/versions/$RUBY_VERSION/bundle"
COPY --from=rails $BUNDLE_PATH $BUNDLE_PATH
COPY --from=rails /app/backend /app/backend

# copy nuxt generate
COPY --from=nuxt /app/frontend/.output/public /app/static

# dockerize
ENV DOCKERIZE_VERSION="v0.8.0"
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# settings nginx
RUN rm -f /etc/nginx/conf.d/* && \
    sed -i "s|www-data|nginx|g" /etc/nginx/nginx.conf && \
    groupadd --system --gid 3000 nginx && \
    useradd nginx --uid 3000 --gid 3000 --create-home --shell /bin/bash && \
    touch /var/run/nginx.pid && \
    mkdir -p /var/log/nginx && \  
    chown -R nginx:nginx /var/log/nginx /var/lib/nginx /var/run/nginx.pid	
COPY ./docker/nginx/app.conf.$APP_ENV /etc/nginx/conf.d/app.conf
ENV CERT_PATH="/etc/ssl/pki"
RUN mkdir -p $CERT_PATH && \
    cd $CERT_PATH && \
    openssl req -x509 -days 36500 -newkey rsa:2048 -nodes -out $DOMAIN_NAME.crt -keyout $DOMAIN_NAME.key -subj "/C=JP/ST=Tokyo/L=null/O=null/OU=null/CN=$DOMAIN_NAME/" && \
    chown -R nginx:nginx $CERT_PATH && \
    chmod 777 $CERT_PATH/* && \
    sed -i "s|DOMAIN_NAME|$DOMAIN_NAME|g" /etc/nginx/conf.d/app.conf

# settings supervisor
COPY ./docker/supervisord/supervisord.conf /etc/supervisor/supervisord.conf
COPY ./docker/supervisord/standalone.conf.$APP_ENV /etc/supervisor/conf.d/standalone.conf
COPY ./docker/supervisord/other_db.conf.$APP_ENV /etc/supervisor/conf.d/other_db.conf
RUN groupadd --system --gid 2000 supervisor && \
    useradd supervisor --uid 2000 --gid 2000 --create-home --shell /bin/bash && \
    mkdir -p /var/log/supervisor && \
    touch /var/run/supervisord.pid && \ 
    chown -R supervisor:supervisor /var/run/supervisord.pid /var/log/supervisor && \
    echo "supervisor ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/supervisor

# settings rails
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails /app/backend

# settings postgresql
COPY ./docker/postgresql/init /docker-entrypoint-initdb.d
RUN chmod +x /docker-entrypoint-initdb.d/*.sh && \
    chown -R postgres:postgres /docker-entrypoint-initdb.d

# init script
COPY ./docker/scripts/init.sh.$APP_ENV /etc/init.d/init.sh
COPY ./docker/scripts/rails.sh.$APP_ENV /etc/init.d/rails.sh
RUN chmod +x /etc/init.d/*.sh

ENTRYPOINT ["/bin/bash"]
CMD [ "/etc/init.d/init.sh" ]
EXPOSE 443

WORKDIR /app

# settings local postgresql
ENV POSTGRES_USER="postgres"
ENV POSTGRES_PASSWORD="postgres"
ENV POSTGRES_DB="kandukasa"

# application settings
ENV APP_ENV=$APP_ENV
ENV RAILS_ENV=$APP_ENV

# set when you needs not local database
ENV DB_HOST="localhost"
ENV DB_ADAPTER="postgresql"
ENV DB_PORT="5432"
ENV DB_USER="kandukasa"
ENV DB_PASSWORD="kandukasa"