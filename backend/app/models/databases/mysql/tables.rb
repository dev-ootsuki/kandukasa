module Databases
  module Mysql
    class Tables < Databases::Auto::Tables
      BLOB_STRING = "** Blob data **"
      def initialize connection_id, schema_id, table_id
        @connection_id = connection_id
        @schema_id = schema_id
        @table_id = table_id
      end

      def find_info base
        {
          :columns => find_columns(base)
        }
      end

      def find_data base, condition
        columns = find_columns base
        column = columns.map{|each|
          # // TODO json, binary, enum ?
          if each["data_type"].downcase == "geometry"
            "ST_AsText(#{each['column_name']}) AS #{each['column_name']}"
          elsif each["data_type"].downcase == "blob"
            "'#{BLOB_STRING}' AS #{each['column_name']}"
          else
            each["column_name"] 
          end
        }.join(", ")
        # // TODO さにたいずする
        query = "SELECT #{column} FROM #{@schema_id}.#{@table_id}"
        base.connection.select_all(query).to_a
      end

      def find_columns base
        query = <<-"EOS"
          select 
            * 
          from 
            information_schema.columns 
          where
            table_schema = ? and table_name = ?
        EOS
        query = base.sanitize_sql_array([query,@schema_id, @table_id])
        base.connection.select_all(query)
        .to_a.map{|record|
          record["id"] = @connection_id
          record["schema_id"] = @schema_id
          record["table_id"] = @table_id
          record["column_id"] = record["COLUMN_NAME"]
          record.transform_keys(&:downcase)
        }
      end
    end
  end
end