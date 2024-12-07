module Databases
  module Mysql
    class Columns < Auto::Columns
      def initialize id, schema_id, table_id, column_id
        @id = id
        @table_id = table_id
        @schema_id = schema_id
        @column_id = column_id
      end
    end
  end
end