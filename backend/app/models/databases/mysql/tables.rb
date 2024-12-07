module Databases
  module Mysql
    class Tables < Databases::Auto::Tables
      BLOB_STRING = "** Blob data **"
      STRING_TYPE = [
        Databases::Mysql::DbInstances::UI_DATA_TYPES[:characters], 
        Databases::Mysql::DbInstances::UI_DATA_TYPES[:enum], 
        Databases::Mysql::DbInstances::UI_DATA_TYPES[:date],
        Databases::Mysql::DbInstances::UI_DATA_TYPES[:datetime],
        Databases::Mysql::DbInstances::UI_DATA_TYPES[:time],
        Databases::Mysql::DbInstances::UI_DATA_TYPES[:binaries]
      ].flatten
      NUMBER_TYPE = Databases::Mysql::DbInstances::UI_DATA_TYPES[:numerics]
      FLOAT_TYPE = Databases::Mysql::DbInstances::UI_DATA_TYPES[:floats]
      GEOMETRY_TYPE = Databases::Mysql::DbInstances::UI_DATA_TYPES[:geometries]
      BLOB_TYPE = Databases::Mysql::DbInstances::UI_DATA_TYPES[:blob]
      BOOL_TYPE = Databases::Mysql::DbInstances::UI_DATA_TYPES[:bool]

      def initialize connection_id, schema_id, table_id
        @connection_id = connection_id
        @schema_id = schema_id
        @table_id = table_id
      end

      def delete_data base, ids
        primaries = find_primary_keys base
        columns = find_columns base, primaries.map{|e| e["column_name"]}
        wheres = to_unique_identifer_query base, primaries, columns, ids
        query = <<-"EOS"
          DELETE FROM #{table_name} WHERE #{wheres}
        EOS
        base.connection.transaction do
          base.connection.execute(query)
        end
      end

      def type_string? col_def
        STRING_TYPE.include? col_def["data_type"]
      end

      def type_number? col_def
        NUMBER_TYPE.include?(col_def["data_type"]) || (BOOL_TYPE.include?(col_def["data_type"]) && !type_bool?(col_def["data_type"]))
      end

      def type_float? col_def
        FLOAT_TYPE.include? col_def["data_type"]
      end

      def type_geometry? col_def
        GEOMETRY_TYPE.include? col_def["data_type"]
      end
      
      def type_blob? col_def
        BLOB_TYPE.include? col_def["data_type"]
      end

      def type_bool? col_def
        BOOL_TYPE.include? col_def["data_type"] && col_def["numeric_precision"] == 1
      end

      def to_geometries_string column_name
        "ST_AsText(#{column_name})"
      end

      def create_data base, data, columns
        q_columns = []
        q_val_meta = []
        q_val = []
        data.each_pair{|k,v|
          col_def = columns.find{|e| e["column_name"] == k}
          unless col_def["extra"] == "auto_increment"
            q_columns << k
            q_val_meta << "?"
            q_val << string_to_type_value(columns.find{|e| e["column_name"] == k}, v)
          end
        }
        query = base.sanitize_sql_array ["INSERT INTO #{table_name} (#{q_columns.join(",")}) VALUES (#{q_val_meta.join(",")})", *q_val]
        base.connection.transaction do
          base.connection.execute(query)
        end
      end

      def find_data base, pagination, conditions, andor
        empty = conditions_empty? conditions
        validate_data_search_params base, conditions unless empty
        columns = find_columns base
        primaries = find_primary_keys base
        column = columns.map{|each|
          # // TODO json, binary, enum ?
          if type_geometry? each
            "#{to_geometries_string(each['column_name'])} AS #{each['column_name']}"
          elsif type_blob? each
            "'#{BLOB_STRING}' AS #{each['column_name']}"
          else
            each["column_name"] 
          end
        }.join(", ")
        wheres = empty ? '' : "WHERE " + conditions.map{|e| 
          to_where_query base, e[:column], e[:operator], e[:input], columns.find{|coldef| coldef["column_name"] == e[:column]}
        }.join(" #{andor} ")

        # 外からSQLを直接叩ける機能がある以上、基本的に全てをサニタイズはしない
        query = "SELECT count(#{columns.first["column_name"]}) AS count FROM #{table_name} #{wheres}"
        total = base.connection.select_all(query).to_a.first["count"]

        orders = pagination[:sortBy].nil? ? "" : "ORDER BY #{pagination[:sortBy]} #{pagination[:descending] ? 'DESC' : ''}"
        paging = "LIMIT #{pagination[:rowsPerPage]} OFFSET #{(pagination[:page] - 1) * pagination[:rowsPerPage]}"

        query = "SELECT #{column} FROM #{table_name} #{wheres} #{orders} #{paging}"
        ret = base.connection.select_all(query).to_a.map{|each|
          unless primaries.empty?
            each[DbStrategy::DB_DATA_PRIMARY_KEY] = primaries.map{|primary|
              each[primary["column_name"]]
            }.join(DbStrategy::MULTI_PRIMARY_KEY_SEPARATOR)
          else
            each[DbStrategy::DB_DATA_PRIMARY_KEY] = each.map{|k, v|
              v
            }.join(DbStrategy::MULTI_PRIMARY_KEY_SEPARATOR)
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

      def find_columns base, column_names = []
        wheres = column_names.empty? ? "" : "AND ( #{column_names.map{|e| "column_name = '#{e}'"}.join(" OR ")} )"
        query = <<-"EOS"
          select 
            * 
          from 
            information_schema.columns 
          where
            table_schema = ? and table_name = ?
            #{wheres}
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
          record["IS_NULLABLE"] = record["IS_NULLABLE"] === "YES" ? true : false
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
          order by
            ordinal_position
        EOS
        query = base.sanitize_sql_array([query, @schema_id, @schema_id, @table_id])
        base.connection.select_all(query).to_a.map{|each|
          each.transform_keys(&:downcase)
        }
      end

      def table_name
        "#{@schema_id}.#{@table_id}"
      end
    end
  end
end