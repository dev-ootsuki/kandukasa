require 'rails_helper'

RSpec.describe Databases::Auto::QueryGenerator, type: :model do
  describe 'generate' do
    context '存在するカラム' do
      mapping = {
        :columns => [{
            :label => "schema_id",
            :mapping => [
              { :belong => "schm", :column => "schema_name"}, # mysql
              { :belong => "schm", :column => "datname"}, # postgresql 
            ]
          }
        ],
        :table => {
          :mapping => [
            { :name => "information_schema.schemata AS schm" }, # mysql
            { :name => "pg_catalog.pg_database schm" }, # postgresql
          ]
        }
      }
      it 'MySQL' do
        query_mysql = Databases::Auto::QueryGenerator.generate 0, mapping
        expect(query_mysql).to eq "SELECT DISTINCT schm.schema_name AS schema_id FROM information_schema.schemata AS schm "
      end
      it 'postgreSQL' do
        query_postgresql = Databases::Auto::QueryGenerator.generate 1, mapping
        expect(query_postgresql).to eq "SELECT DISTINCT schm.datname AS schema_id FROM pg_catalog.pg_database schm "
      end
    end

    context '存在しないカラム' do
      mapping = {
        :columns => [{
            :label => "schema_id",
            :mapping => [
              { :belong => nil, :column => Databases::Auto::QueryGenerator::UNSUPPORTED}, # mysql
              { :belong => nil, :column => Databases::Auto::QueryGenerator::UNSUPPORTED}, # postgresql 
            ]
          }
        ],
        :table => {
          :mapping => [
            { :name => "information_schema.schemata AS schm" }, # mysql
            { :name => "pg_catalog.pg_database schm" }, # postgresql
          ]
        }
      }
      it 'MySQL' do
        query_mysql = Databases::Auto::QueryGenerator.generate 0, mapping
        expect(query_mysql).to eq "SELECT DISTINCT #{Databases::Auto::QueryGenerator::UNSUPPORTED} AS schema_id FROM information_schema.schemata AS schm "
      end
      it 'postgreSQL' do
        query_postgresql = Databases::Auto::QueryGenerator.generate 1, mapping
        expect(query_postgresql).to eq "SELECT DISTINCT #{Databases::Auto::QueryGenerator::UNSUPPORTED} AS schema_id FROM pg_catalog.pg_database schm "
      end
    end

    context 'カラムを関数に渡す' do
      mapping = {
        :columns => [{
          :label => "encoding",
          :mapping => [
            { :belong => "schm", :column => "default_character_set_name" },        # MySQL
            { :belong => nil, :column => "pg_encoding_to_char(schm.encoding)" }, # postgreSQL
          ]
        }],
        :table => {
          :mapping => [
            { :name => "information_schema.schemata AS schm" }, # mysql
            { :name => "pg_catalog.pg_database schm" }, # postgresql
          ]
        }
      }
      it 'MySQL' do
        query_mysql = Databases::Auto::QueryGenerator.generate 0, mapping
        expect(query_mysql).to eq "SELECT DISTINCT schm.default_character_set_name AS encoding FROM information_schema.schemata AS schm "
      end
      it 'postgreSQL' do
        query_postgresql = Databases::Auto::QueryGenerator.generate 1, mapping
        expect(query_postgresql).to eq "SELECT DISTINCT pg_encoding_to_char(schm.encoding) AS encoding FROM pg_catalog.pg_database schm "
      end
    end

    context 'table joinしてjoinしたカラムを指定' do
      mapping = {
        :columns => [{
          :label => "schema_id",
          :mapping => [
            { :belong => "schm", :column => "schema_name"}, # mysql
            { :belong => "schm", :column => "datname"}, # postgresql 
          ]
        },{
          :label => "owner_name",
          :mapping => [
            { :belong => nil, :column => Databases::Auto::QueryGenerator::UNSUPPORTED }, # MySQL
            { :belong => "auth", :column => "rolname"}, # postgreSQL
          ]
        }],
        :table => {
          :mapping => [
            { :name => "information_schema.schemata AS schm" }, # mysql
            { :name => "pg_catalog.pg_database schm" }, # postgresql
          ]
        },
        :joins => [ {
            :shortcut => "auth",
            :mapping => [
              { :name => nil }, # mysql
              { :name => "pg_authid", :on => "auth.oid = schm.datdba"}, # postgresql
            ]
          },{
            :shortcut => "space",
            :mapping => [
              { :name => nil }, # mysql
              { :name => "pg_tablespace", :on => "space.oid = schm.dattablespace"}, # postgresql
            ]
          }
        ]
      }
      it 'MySQL' do
        query_mysql = Databases::Auto::QueryGenerator.generate 0, mapping
        expect(query_mysql).to eq "SELECT DISTINCT schm.schema_name AS schema_id, #{Databases::Auto::QueryGenerator::UNSUPPORTED} AS owner_name FROM information_schema.schemata AS schm "
      end
      it 'postgreSQL' do
        query_postgresql = Databases::Auto::QueryGenerator.generate 1, mapping
        expect(query_postgresql).to eq "SELECT DISTINCT schm.datname AS schema_id, auth.rolname AS owner_name FROM pg_catalog.pg_database schm LEFT JOIN pg_authid auth ON auth.oid = schm.datdba LEFT JOIN pg_tablespace space ON space.oid = schm.dattablespace "
      end
    end

    context 'order byを指定' do
      mapping = {
        :columns => [{
            :label => "schema_id",
            :mapping => [
              { :belong => "schm", :column => "schema_name"}, # mysql
              { :belong => "schm", :column => "datname"}, # postgresql 
            ]
          }
        ],
        :table => {
          :mapping => [
            { :name => "information_schema.schemata AS schm" }, # mysql
            { :name => "pg_catalog.pg_database schm" }, # postgresql
          ]
        },
        :orders => ["schema_id"]
      }
      it 'MySQL' do
        query_mysql = Databases::Auto::QueryGenerator.generate 0, mapping
        expect(query_mysql).to eq "SELECT DISTINCT schm.schema_name AS schema_id FROM information_schema.schemata AS schm ORDER BY schema_id"
      end
      it 'postgreSQL' do
        query_postgresql = Databases::Auto::QueryGenerator.generate 1, mapping
        expect(query_postgresql).to eq "SELECT DISTINCT schm.datname AS schema_id FROM pg_catalog.pg_database schm ORDER BY schema_id"
      end
    end

    context 'order byを複数指定かつDESC指定' do
      mapping = {
        :columns => [{
            :label => "schema_id",
            :mapping => [
              { :belong => "schm", :column => "schema_name"}, # mysql
              { :belong => "schm", :column => "datname"}, # postgresql 
            ]
          },{
            :label => "default_character_set_name",
            :mapping => [
              { :belong => "schm", :column => "default_character_set_name" },        # MySQL
              { :belong => "schm", :column => "datctype" }, # postgreSQL
            ]
          }
        ],
        :table => {
          :mapping => [
            { :name => "information_schema.schemata AS schm" }, # mysql
            { :name => "pg_catalog.pg_database schm" }, # postgresql
          ]
        },
        :orders => ["schema_id DESC", "default_character_set_name DESC"]
      }
      it 'MySQL' do
        query_mysql = Databases::Auto::QueryGenerator.generate 0, mapping
        expect(query_mysql).to eq "SELECT DISTINCT schm.schema_name AS schema_id, schm.default_character_set_name AS default_character_set_name FROM information_schema.schemata AS schm ORDER BY schema_id DESC, default_character_set_name DESC"
      end
      it 'postgreSQL' do
        query_postgresql = Databases::Auto::QueryGenerator.generate 1, mapping
        expect(query_postgresql).to eq "SELECT DISTINCT schm.datname AS schema_id, schm.datctype AS default_character_set_name FROM pg_catalog.pg_database schm ORDER BY schema_id DESC, default_character_set_name DESC"
      end
    end

    context 'where句' do
      mapping = {
        :columns => [{
            :label => "schema_id",
            :mapping => [
              { :belong => "schm", :column => "schema_name"}, # mysql
              { :belong => "schm", :column => "datname"}, # postgresql 
            ]
          }
        ],
        :table => {
          :mapping => [
            { :name => "information_schema.schemata AS schm" }, # mysql
            { :name => "pg_catalog.pg_database schm" }, # postgresql
          ]
        },
        :where => {
          :target => "schema_id",
          :operator => "=",
          :converter => [
            ->(val){ "'#{val}'" }, # mysql
            ->(val){ "'#{val}'" }  # postgresql
          ]
        }, 
        :orders => ["schema_id"]
      }
      it 'MySQL' do
        query_mysql = Databases::Auto::QueryGenerator.generate 0, mapping, ["information_schema"]
        expect(query_mysql).to eq "SELECT DISTINCT schm.schema_name AS schema_id FROM information_schema.schemata AS schm WHERE schm.schema_name = 'information_schema' ORDER BY schema_id"
      end
      it 'postgreSQL' do
        query_postgresql = Databases::Auto::QueryGenerator.generate 1, mapping, ["information_schema"]
        expect(query_postgresql).to eq "SELECT DISTINCT schm.datname AS schema_id FROM pg_catalog.pg_database schm WHERE schm.datname = 'information_schema' ORDER BY schema_id"
      end
    end
  end
end