module Databases
  module Auto
    class Schemas
      def truncate_tables base, ids
        base.connection.transaction do
          ids.each{|e|
            base.connection.execute("TRUNCATE TABLE #{@schema_id}.#{e}")
          }
        end
      end

      def delete_tables base, ids
        base.connection.transaction do
          ids.each{|e|
            base.connection.execute("DROP TABLE #{@schema_id}.#{e}")
          }
        end
      end
    end
  end
end