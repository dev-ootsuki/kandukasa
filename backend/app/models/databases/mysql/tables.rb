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

      def type_datetime? col_def
        Databases::Mysql::DbInstances::UI_DATA_TYPES[:date].include?(col_def["data_type"]) || Databases::Mysql::DbInstances::UI_DATA_TYPES[:datetime].include?(col_def["data_type"])
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

      def update_data base, data, columns
        primaries = find_primary_keys base
        q_columns_meta = []
        q_val = []
        data.each_pair{|k,v|
          col_def = columns.find{|e| e["column_name"] == k}
          unless col_def["extra"] == "auto_increment"
            q_columns_meta << "#{k} = ?"
            q_val << string_to_type_value(columns.find{|e| e["column_name"] == k}, v)
          end
        }
        wheres = primaries.map{|e|
          q_val << string_to_type_value(e, data[e["column_name"]])
          "#{e["column_name"]} = ?"
        }.join(" AND ")
        query = base.sanitize_sql_array ["UPDATE #{table_name} SET #{q_columns_meta.join(",")} WHERE #{wheres}", *q_val]
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
        datetime_columns = columns.filter{|e| type_datetime? e}
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
            datetime_columns.each{|e|
              each[e["column_name"]] = each[e["column_name"]].strftime DbStrategy::DATETIME_FORMAT
            }
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

      def find_foreign_keys base
        query = <<-"EOS"
          select 
            kcu.*
          from
            information_schema.table_constraints tc
          inner join
            information_schema.key_column_usage kcu
          on
            kcu.table_schema = tc.table_schema and kcu.table_name = tc.table_name and tc.constraint_name = kcu.constraint_name
          where
            tc.constraint_type = 'FOREIGN KEY' and
            tc.table_schema = ? and
            tc.table_name = ? 
          order by
            ordinal_position
        EOS
        query = base.sanitize_sql_array([query, @schema_id, @table_id])
        base.connection.select_all(query).to_a.map{|each|
          each["id"] = each["CONSTRAINT_NAME"]
          each.transform_keys(&:downcase)
        }
      end

      def find_indexes base
        # 最初にindexesの名前と定義を取得して
        # 2回目のSQLで対象のカラムの定義を取ってきて
        # 最後に1-2回目をマージする

        # statisticsからindex定義を取ってくるが複合indexの場合に複数レコードになっているので
        # group byしつつ集約関数で取ってくる
        query = <<-"EOS"
          select 
            index_name, group_concat(column_name ORDER BY seq_in_index SEPARATOR ", ") as column_names, non_unique, collation, sub_part, packed, nullable, index_type, comment, index_comment, is_visible, expression
          from 
            information_schema.statistics
          where
            table_schema = ? and
            table_name = ?
          group by 
            index_name, non_unique, collation, sub_part, packed, nullable, index_type, comment, index_comment, is_visible, expression
        EOS
        query = base.sanitize_sql_array([query, @schema_id, @table_id])
        column_names = []
        indexes = base.connection.select_all(query).to_a.map{|each|
          # indexのリストの各要素にcolumnsを追加して集約関数で纏めたやつをバラす
          # 今は名前だけのリストにしているが最終的に定義に置き換える
          each["columns"] = each["column_names"].split(", ")
          column_names << each["columns"]
          each["IS_VISIBLE"] = each["IS_VISIBLE"] ? true : false
          each["id"] = each["INDEX_NAME"]
          each.transform_keys(&:downcase)
        }
        # indexの各カラムをカラム定義から取ってくる
        def_columns = find_columns base, column_names.flatten.uniq

        # 結果をマージする
        indexes.each{|index|
          coldefs = []
          index["columns"].each{|col_name|
            coldefs << def_columns.find{|coldef| coldef["column_name"] == col_name}
          }
          index["columns"] = coldefs
        }
        indexes
      end
      
      def delete_fkeys base, keys
        base.connection.transaction do
          keys.each{|e|
            base.connection.execute "ALTER TABLE #{table_name} DROP FOREIGN KEY #{e}"
          }
        end
      end

      def create_fkey base, fkey_name, ref_table, ref_column
        base.connection.transaction do
          base.connection.execute "ALTER TABLE #{table_name} ADD FOREIGN KEY #{fkey_name} REFERENCES #{ref_table} (#{ref_column})"
        end
      end
    end
  end
end