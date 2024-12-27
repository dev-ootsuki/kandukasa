#!/bin/bash
mysql -uroot -ptest -e'drop database sakila;'
mysql -uroot -ptest -e'drop database world;'

echo '********** restore sakia **********'
cp -f /docker-entrypoint-initdb.d/sakila-db.tar.gz /tmp/
cd /tmp
tar xfvz sakila-db.tar.gz
mysql -uroot -ptest < ./sakila-db/sakila-schema.sql
mysql -uroot -ptest < ./sakila-db/sakila-data.sql
rm -rf sakila-db*

echo '********** restore world **********'
cp -f /docker-entrypoint-initdb.d/world-db.tar.gz /tmp/
cd /tmp
tar xfvz world-db.tar.gz
mysql -uroot -ptest < ./world-db/world.sql
rm -rf world-db*

