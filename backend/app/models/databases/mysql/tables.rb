module Databases
  module Mysql
    class Tables < Databases::Auto::Tables
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
        column = columns.map{|each| each["column_name"] }.join(", ")
        # // TODO さにたいずする
        query = "SELECT #{column} FROM #{@schema_id}.#{@table_id}"
        targets = columns.select{|each| each["data_type"] == "varchar" || each["data_type"] == "text" }
        base.connection.select_all(query).to_a.map{|each|
          # // TODO 文字列で\xの文字が入っているデータを補正しないとjsonにできない
          
          # targets.each{|target| 
          #   each[target["column_name"]] = each[target["column_name"]]&.chars&.map{|b| b.unpack 'C' }&.join('.')
          # }
          each
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