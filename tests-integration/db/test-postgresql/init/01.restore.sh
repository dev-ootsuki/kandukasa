#!/bin/bash
tar zxvf world-1.0.tar.gz

createdb -U postgres world
psql -U postgres -f dbsamples-0.1/world-1.0/world.sql world
createdb -U postgres dvdrental
pg_restore -h localhost -p 5432 -U postgres -d dvdrental dvdrental.tar
rm -rf dbsamples-0.1/