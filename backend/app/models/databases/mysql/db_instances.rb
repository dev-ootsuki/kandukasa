module Databases
  module Mysql
    class DbInstances < Databases::Auto::DbInstance
      def initialize connection_id, type_id, hide_system_schema
        @type_id = type_id
        @connection_id = connection_id
        @hide_system_schema = hide_system_schema
      end

      def find_character_sets base
        query = <<-"EOS"
          SELECT 
            character_set_name, default_collate_name, description, maxlen
          FROM 
            information_schema.character_sets
        EOS
        base.connection.select_all(query).to_a.map{|record| record.transform_keys(&:downcase) }
      end

      def find_users_privileges base
        query = <<-"EOS"
          (
            SELECT 
              grantee AS grantee, '*' AS table_schema, '*' AS table_name, '*' AS column_name, 
              GROUP_CONCAT(privilege_type ORDER BY privilege_type) AS privileges
            FROM 
              information_schema.user_privileges
            GROUP BY 
              grantee
          )
          UNION(
            SELECT 
              grantee AS grantee, table_schema AS table_schema, '*' AS table_name, '*' AS column_name, 
              GROUP_CONCAT(privilege_type ORDER BY privilege_type) AS privileges 
            FROM 
              information_schema.schema_privileges 
            GROUP BY 
              grantee, table_schema
          )
          UNION(
            SELECT 
              grantee AS grantee, table_schema AS table_schema, table_name AS table_name, '*' AS column_name, 
              GROUP_CONCAT(privilege_type ORDER BY privilege_type) AS privileges 
            FROM 
              information_schema.table_privileges 
            GROUP BY 
              grantee, table_schema, table_name
          )
          UNION(
            SELECT 
              grantee AS grantee, table_schema AS table_schema, table_name AS table_name, column_name AS column_name, 
              GROUP_CONCAT(privilege_type ORDER BY privilege_type) AS privileges 
            FROM 
              information_schema.column_privileges 
            GROUP BY 
              grantee, table_schema, table_name, column_name
          )
          ORDER BY grantee, table_schema, table_name, column_name      
        EOS
        base.connection.select_all(query).to_a.map{|record| record.transform_keys(&:downcase) }
      end

      def find_available_engines base
        query = <<-"EOS"
          SELECT 
            engine, support, comment, transactions, xa, savepoints
          FROM 
            information_schema.engines
          WHERE
            support != 'NO'
        EOS
        base.connection.select_all(query).to_a.map{|record| record.transform_keys(&:downcase) }
      end
    end
  end
end