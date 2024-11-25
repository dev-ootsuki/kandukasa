# syntax = docker/dockerfile:1
#############################################################################################################
# LDAP テスト用
#############################################################################################################

# 2024/11/20 最新版
FROM osixia/openldap:1.5.0
LABEL maintainer="dev-ootsuki"
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131

RUN sed -i "s|deb http://ftp.debian.org/debian buster-backports main|deb http://archive.debian.org/debian buster-backports main|g" /etc/apt/sources.list
# 構築に必要なソフトウェアを入れる
RUN apt-get update && apt-get install -y wget

# slapdが起動したあとにユーザーを登録したいのでdockerizeで待てるようにする
ENV DOCKERIZE_VERSION="v0.8.0"
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    tar -C /usr/local/bin -xzvf dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz && \
    rm dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz

# osixiaと追加分の環境変数を設定
ENV CERT_PATH="/container/service/slapd/assets/certs"
ENV APP_NAME="kandukasa-ldap"
ENV LDAP_TLS_CRT_FILENAME="$APP_NAME.crt"
ENV LDAP_TLS_KEY_FILENAME="$APP_NAME.key"
ENV LDAP_TLS_CA_CRT_FILENAME="$APP_NAME.crt"
ENV LDAP_TLS_VERIFY_CLIENT="allow"
ENV LDAP_DOMAIN="$APP_NAME"
ENV LDAP_ADMIN_PASSWORD="kandukasa"
ENV LDAP_CONFIG_PASSWORD="kandukasa"
ENV LDAP_ORGANISATION="kandukasa"
ENV LDAP_DATA_PATH /data/ldap
ENV LDAP_SEED_INTERNAL_SCHEMA_PATH="$LDAP_DATA_PATH/slapd.d/schema"

# 実行スクリプト色々を追加
COPY ./scripts/ /usr/local/bin

# certを作る
RUN mkdir -p $CERT_PATH && \
    chmod +x /usr/local/bin/*.sh && \
    /usr/local/bin/ssl.sh $LDAP_DOMAIN $LDAP_CONFIG_PASSWORD $CERT_PATH

# カスタムスキーマとユーザ追加用設定
RUN mkdir -p $LDAP_DATA_PATH && \ 
    echo "100000" >> $LDAP_DATA_PATH/userid_counter && \ 
    chmod -R +x /usr/local/bin/ && \ 
    groupadd -g 5000 kandukasa && \ 
    mkdir -p /container/service/slapd/assets/config/bootstrap/schema/custom

ADD ./users.txt $LDAP_DATA_PATH/user_list.txt
ADD ./slapd.d/ $LDAP_DATA_PATH/slapd.d

ENTRYPOINT ["/usr/local/bin/start.sh"]