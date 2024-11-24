#!/bin/bash
cp -f dvdrental.zip /tmp/
cp -f world-1.0.tar.gz /tmp/
cd /tmp
tar zxvf usda-r18-1.0.tar.gz
tar xfv dvdrental.zip

createdb -U postgres usda
psql -U postgres -f ./usda-r18-1.0/usda.sql usda
createdb -U postgres dvdrental
pg_restore -h localhost -p 5432 -U postgres -d dvdrental ./dvdrental.tar