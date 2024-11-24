module Databases
  module Postgresql
    class Schemas
      def initialize connection_id, schema_id
        @connection_id = connection_id
        @schema_id = schema_id
      end

      def find_info base
        { 
          :tables => find_tables(base),
          :triggers => find_triggers(base),
          :views => find_views(base),
          :events => [],#find_events(base),
          :routines => find_routines(base)
        }
      end

      def find_tables base
        query = <<-"EOS"
          SELECT 
            relname
          FROM 
            pg_class
          WHERE
            relname = ?
        EOS
        query = base.sanitize_sql_array([query, @schema_id])
        base.connection.reconnect!
        ret = base.connection.execute(query).to_a.map{|record|
          record["id"] = @connection_id
          record["schema_id"] = @schema_id
          record["table_id"] = record["TABLE_NAME"]
          record.transform_keys(&:downcase)
        }
        p ret
        ret
      end

      def find_triggers base
        query = <<-"EOS"
          select 
            * 
          from 
            information_schema.triggers 
          where
            trigger_schema = ?
        EOS
        query = base.sanitize_sql_array([query,@schema_id])
        base.connection.select_all(query)
        .to_a.map{|record|
          record["id"] = @connection_id
          record["schema_id"] = @schema_id
          record["trigger_id"] = record["TRIGGER_NAME"]
          record.transform_keys(&:downcase)
        }
      end

      def find_views base
        query = <<-"EOS"
          select 
            * 
          from 
            information_schema.views 
          where
            table_schema = ?
        EOS
        query = base.sanitize_sql_array([query,@schema_id])
        base.connection.select_all(query)
        .to_a.map{|record|
          record["id"] = @connection_id
          record["schema_id"] = @schema_id
          record["view_id"] = record["TABLE_NAME"]
          record.transform_keys(&:downcase)
        }
      end

      def find_events base
        query = <<-"EOS"
          select 
            * 
          from 
            information_schema.events 
          where
            event_schema = ?
        EOS
        query = base.sanitize_sql_array([query,@schema_id])
        base.connection.select_all(query)
        .to_a.map{|record|
          record["id"] = @connection_id
          record["schema_id"] = @schema_id
          record["event_id"] = record["EVENT_NAME"]
          record.transform_keys(&:downcase)
        }
      end

      def find_routines base
        query = <<-"EOS"
          select 
            * 
          from 
            information_schema.routines
          where
            routine_schema = ?
        EOS
        query = base.sanitize_sql_array([query,@schema_id])
        base.connection.select_all(query)
        .to_a.map{|record|
          record["id"] = @connection_id
          record["schema_id"] = @schema_id
          record["routine_id"] = record["ROUTINE_NAME"]
          record.transform_keys(&:downcase)
        }
      end
    end
  end
end