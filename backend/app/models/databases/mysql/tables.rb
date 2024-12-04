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

      def to_unique_identifer_query base, primaries, columns, ids
        ids.map.with_index{|id, idx|
          ret = id.split(DbStrategy::MULTI_PRIMARY_KEY_SEPARATOR).map.with_index{|pkeys, pidx|
            col = columns[pidx]
            col_name = col["column_name"]
            col_dtype = col["data_type"]
            if STRING_TYPE.include? col_dtype
              "#{col_name} = '#{id}'"
            elsif NUMBER_TYPE.include? col_dtype
              "#{col_name} = #{id.to_i}"
            elsif FLOAT_TYPE.include? col_dtype
              "#{col_name} = #{id.to_f}"
            elsif GEOMETRY_TYPE.include? col_dtype
              "#{col_name} = ST_GeomFromText('#{id}')"
            else
              "#{col_name} = '#{id}'"
            end
          }.join(" AND ")
          "( #{ret} )"
        }.join(" OR ")
      end

      def find_data base, pagination, condition
        columns = find_columns base
        primaries = find_primary_keys base
        column = columns.map{|each|
          # // TODO json, binary, enum ?
          if GEOMETRY_TYPE.include? each["data_type"].downcase
            "ST_AsText(#{each['column_name']}) AS #{each['column_name']}"
          elsif BLOB_TYPE.include? each["data_type"].downcase
            "'#{BLOB_STRING}' AS #{each['column_name']}"
          else
            each["column_name"] 
          end
        }.join(", ")

        # // TODO 一応サニタイズしたい
        query = "SELECT count(#{columns.first["column_name"]}) AS count FROM #{table_name}"
        total = base.connection.select_all(query).to_a.first["count"]

        orders = pagination[:sortBy].nil? ? "" : "ORDER BY #{pagination[:sortBy]} #{pagination[:descending] ? 'DESC' : ''}"
        limits = "LIMIT #{pagination[:rowsPerPage]} OFFSET #{(pagination[:page] - 1) * pagination[:rowsPerPage]}"

        query = "SELECT #{column} FROM #{table_name} #{orders} #{limits}"
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

      def find_columns base, column_names = nil
        wheres = column_names.nil? ? "" : "AND ( #{column_names.map{|e| "column_name = '#{e}'"}.join(" OR ")} )"
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