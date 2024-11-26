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
          :columns => find_columns(base),
          :primaries => find_primary_keys(base)
        }
      end

      def find_data base, pagination, condition
        columns = find_columns base
        primaries = find_primary_keys base
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

        # // TODO 一応サニタイズしたい
        query = "SELECT count(#{columns.first["column_name"]}) AS count FROM #{@schema_id}.#{@table_id}"
        total = base.connection.select_all(query).to_a.first["count"]

        orders = pagination[:sortBy].nil? ? "" : "ORDER BY #{pagination[:sortBy]} #{pagination[:descending] ? 'DESC' : ''}"
        limits = "LIMIT #{pagination[:rowsPerPage]} OFFSET #{(pagination[:page] - 1) * pagination[:rowsPerPage]}"

        query = "SELECT #{column} FROM #{@schema_id}.#{@table_id} #{orders} #{limits}"
        ret = base.connection.select_all(query).to_a.map{|each|
          unless primaries.empty?
            each["_internal_kandukasa_exchange_id_"] = primaries.map{|primary|
              each[primary["column_name"]]
            }.join(",")
          else
            each["_internal_kandukasa_exchange_id_"] = each.map{|k, v|
              v
            }.join(",")
          end
          each
        }
        {
          :results => ret,
          :pagination => {
            :rowsNumber => total,
            :page => pagination[:page],
            :rowsPerPage => pagination[:rowsPerPage],
            :sortBy => pagination[:sortBy],
            :descending => pagination[:descending]
          }
        }
      end

      def find_columns base
        query = <<-"EOS"
          select 
            * 
          from 
            information_schema.columns 
          where
            table_schema = ? and table_name = ?
          order by
            ordinal_position
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

      def find_primary_keys base
        query = <<-"EOS"
          select 
            *
          from 
            information_schema.key_column_usage
          where
            constraint_schema = ? and
            table_schema = ? and
            table_name = ? and 
            constraint_name = 'PRIMARY'
        EOS
        query = base.sanitize_sql_array([query, @schema_id, @schema_id, @table_id])
        base.connection.select_all(query).to_a.map{|each|
          each.transform_keys(&:downcase)
        }
      end
    end
  end
end