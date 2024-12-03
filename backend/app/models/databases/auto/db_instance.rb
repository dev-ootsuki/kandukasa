module Databases
  module Auto
    class DbInstance
      SCHEMA_NAME = "schm"

      def generate_query db_type_id, mapping, *param
        QueryGenerator::generate db_type_id, mapping, *param
      end

      def find_info base
        { 
          :schemas => find_schmemas(base),
          :characters => find_character_sets(base),
          :privileges => find_users_privileges(base),
          :engines => find_available_engines(base),
          :collations => find_collations(base),
          :ui_data_types => find_ui_db_data_mapping(base)
        }
      end

      def find_schmemas base
        conditions = @hide_system_schema ? @@system_schemas[@type_id] : []
        query = generate_query @type_id, @@mappings[:schema_info], *conditions
        base.connection.select_all(query).to_a.map{|each|
          each[:id] = @connection_id
          each
        }
      end
      
      def find_collations base
        query = generate_query @type_id, @@mappings[:collation_info]
        base.connection.select_all(query).to_a
      end

      @@system_schemas = [
        ["sys", "mysql", "information_schema", "performance_schema"], # mysql
        ["template0", "template1", "postgres"], # postgresql
      ]
      @@defualt_converter = ->(val){ val }
      @@escape_converter = ->(val){ "'#{val}'" }
      @@mappings = {
        :collation_info => {
          :columns => [{
            :label => "collation_name",
            :mapping => [
              { :belong => "cll", :column => "collation_name"}, # mysql
              { :belong => "cll", :column => "collname"}, # postgresql
            ]
          },{
            :label => "description",
            :mapping => [
              { :belong => "cll", :column => "character_set_name"}, # mysql
              { :belong => "cll", :column => "colllocale"}, # postgresql
            ]            
          }],
          :table => {
            :mapping => [
              { :name => "information_schema.collations AS cll" }, # mysql
              { :name => "pg_catalog.pg_collation cll" }, # postgresql
            ]
          },
          :orders => ["collation_name"]
        },
        :schema_info => {
          :columns => [{
              :label => "system_catalog",
              :mapping => [
                { :belong => "schm", :column => "catalog_name" },     # MySQL
                { :belong => nil, :column => Databases::Auto::QueryGenerator::UNSUPPORTED }, # postgreSQL
              ]
            },{
              :label => "schema_id",
              :mapping => [
                { :belong => "schm", :column => "schema_name"}, # mysql
                { :belong => "schm", :column => "datname"}, # postgresql 
              ]
            },{
              :label => "schema_name",
              :mapping => [
                { :belong => "schm", :column => "schema_name" }, # MySQL
                { :belong => "schm", :column => "datname" },      # postgreSQL
              ]
            },{
              :label => "encoding",
              :mapping => [
                { :belong => "schm", :column => "default_character_set_name" },        # MySQL
                { :belong => nil, :column => "pg_encoding_to_char(schm.encoding)" }, # postgreSQL
              ]
            },{
              :label => "default_character_set_name",
              :mapping => [
                { :belong => "schm", :column => "default_character_set_name" },        # MySQL
                { :belong => "schm", :column => "datctype" }, # postgreSQL
              ]
            },{
              :label => "default_collation_name",
              :mapping => [
                { :belong => "schm", :column => "default_collation_name" }, # MySQL
                { :belong => "schm", :column => "datcollate" }, # postgreSQL
              ]
            },{
              :label => "connections_limit",
              :mapping => [
                { :belong => nil, :column => Databases::Auto::QueryGenerator::UNSUPPORTED }, # MySQL
                { :belong => "schm", :column => "datconnlimit" }, # postgreSQL
              ]
            },{
              :label => "owner_name",
              :mapping => [
                { :belong => nil, :column => Databases::Auto::QueryGenerator::UNSUPPORTED }, # MySQL
                { :belong => "auth", :column => "rolname"}, # postgreSQL
              ]
            },{
              :label => "belongs_space",
              :mapping => [
                { :belong => nil, :column => Databases::Auto::QueryGenerator::UNSUPPORTED }, # mysql
                { :belong => "space", :column => "spcname"}, # postgresql
              ]
            },{
              :label => "default_encryption",
              :mapping => [
                { :belong => "schm", :column => "default_encryption" }, # mysql
                { :belong => nil, :column => Databases::Auto::QueryGenerator::UNSUPPORTED }, # postgresql
              ]
            }
          ],
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
          ],
          :where => {
            :target => "schema_name",
            :operator => "NOT IN",
            :converter => [
              @@escape_converter, # mysql
              @@escape_converter  # postgresql
            ]
          },
          :orders => ["schema_name"]
        }
      }
    end
  end
end