class DbStrategy
  DB_DATA_PRIMARY_KEY = "_internal_kandukasa_exchange_id_"
  MULTI_PRIMARY_KEY_SEPARATOR = "_internal_kandukasa_multi_pkey_separator"
  DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S"
  DB_STRATEGRY_SETTING = {
    :MySQL => {
      :type_id => 0,
      :rubygem => "mysql2",
      :db_instance => 'Databases::Mysql::DbInstances',
      :schema => 'Databases::Mysql::Schemas',
      :table => 'Databases::Mysql::Tables',
      :column => 'Databases::Mysql::Columns'
    },
    :postgreSQL => {
      :type_id => 1,
      :rubygem => "postgresql",
      :db_instance => 'Databases::Postgresql::DbInstances',
      :schema => 'Databases::Postgresql::Schemas',
      :table => 'Databases::Postgresql::Tables',
      :column => 'Databases::Postgresql::Columns'
    },
    :AuroraMySQL => {
      :type_id => 0,
      :rubygem => "mysql2",
      :db_instance => 'Databases::Mysql::DbInstances',
      :schema => 'Databases::Mysql::Schemas',
      :table => 'Databases::Mysql::Tables',
      :column => 'Databases::Mysql::Columns'
    }
  }

  def initialize con_id, schema_id = nil, table_id = nil, column_id = nil
    @connection_id = con_id
    @schema_id = schema_id
    @table_id = table_id
    @column_id = column_id
    load_primary_config
  end

  def db_server_info hide_system_schema
      db_instance = get_db_mapping[:db_instance].camelize.constantize.new(@connection_id, get_db_mapping[:type_id], hide_system_schema)
      ret = establish{|con|
        {
          db_instance: establish{|con|
            db_instance.find_info con
          },
          id: @connection_id
        }
      }
      close_connection
      ret
  end

  def schema_info
    # TODO インスタンス生成のコードが重複しているし呼び出しの箇所(estalibsh)も重複しているので後でなんとかする
    db_schema = get_db_mapping[:schema].camelize.constantize.new(@connection_id, @schema_id)
    ret = establish{|con|
      db_schema.find_info con
    }
    close_connection
    ret
  end

  def truncate_tables ids
    db_schema = get_db_mapping[:schema].camelize.constantize.new(@connection_id, @schema_id)
    ret = establish{|con|
      db_schema.truncate_tables con, ids
    }
    close_connection
    ret    
  end

  def delete_tables ids
    db_schema = get_db_mapping[:schema].camelize.constantize.new(@connection_id, @schema_id)
    ret = establish{|con|
      db_schema.delete_tables con, ids
    }
    close_connection
    ret    
  end

  def table_info
    db_table = get_db_mapping[:table].camelize.constantize.new(@connection_id, @schema_id, @table_id)
    ret = establish{|con|
      db_table.find_info con
    }
    close_connection
    ret
  end

  def table_columns
    db_table = get_db_mapping[:table].camelize.constantize.new(@connection_id, @schema_id, @table_id)
    ret = establish{|con|
      db_table.find_columns con
    }
    close_connection
    ret
  end

  def delete_pkey
    db_table = get_db_mapping[:table].camelize.constantize.new(@connection_id, @schema_id, @table_id)
    ret = establish{|con|
      db_table.delete_pkey con
    }
    close_connection
    ret
  end

  def table_data pagination, condition, andor
    db_table = get_db_mapping[:table].camelize.constantize.new(@connection_id, @schema_id, @table_id)
    ret = establish{|con|
      db_table.find_data con, pagination, condition, andor
    }
    close_connection
    ret
  end

  def create_table_data data, columns
    db_table = get_db_mapping[:table].camelize.constantize.new(@connection_id, @schema_id, @table_id)
    ret = establish{|con|
      db_table.create_data con, data, columns
    }
    close_connection
    ret
  end

  def update_table_data data, columns
    db_table = get_db_mapping[:table].camelize.constantize.new(@connection_id, @schema_id, @table_id)
    ret = establish{|con|
      db_table.update_data con, data, columns
    }
    close_connection
    ret
  end

  def delete_data ids
    db_table = get_db_mapping[:table].camelize.constantize.new(@connection_id, @schema_id, @table_id)
    ret = establish{|con|
      db_table.delete_data con, ids
    }
    close_connection
    ret
  end

  def delete_column
    db_column = get_db_mapping[:column].camelize.constantize.new(@connection_id, @schema_id, @table_id, @column_id)
    ret = establish{|con|
      db_column.delete_column con
    }
    close_connection
    ret
  end

  def establish
    # TODO 接続がいけてないのでconnectioin_handlingかconnection_poolをハックしていい感じにしたい
    # TODO できればコネクションはDB製品別の方がいいかもしれない＠要検討
    ActiveRecord::Base.establish_connection @config
    @connection = ActiveRecord::Base
    if block_given?
      yield(@connection) 
    else 
      @connection
    end
  end

  def connection_id
    @connection_id
  end

  private
  def close_connection
    @connection.connection.disconnect!
  end

  def get_db_mapping
    DB_STRATEGRY_SETTING[@settings.db_type.to_sym]
  end

  def load_primary_config
    DbConnection.primary{
      @settings = DbConnection.find(@connection_id)
    }
    @config = {
      :adapter => get_db_mapping[:rubygem], 
      :encoding => 'utf8',
      :database => @schema_id.nil? ? @settings.default_database_name : @schema_id,
      :pool => 1,
      :username => @settings.login_name,
      :password => @settings.password,
      :host => @settings.host,
      :port => @settings.port
    }
    DbConnection.connection.disconnect!
    Rails.logger.info @config
  end
end
