module Databases
  module Auto
    class Columns
      def table_name
        "#{@schema_id}.#{@table_id}"
      end
      
      def delete_column base
        base.connection.transaction do
          base.connection.execute("ALTER TABLE #{table_name} DROP COLUMN #{@column_id}")
        end        
      end
    end
  end
end