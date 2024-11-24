class SchemasController < ApplicationController
  include ResponseFormattingConcern

  # URLに指定された接続先IDのDBインスタンス情報（スキーマ一覧含む）を取得する
  def show
    id = params.require(:con_id)
    begin
      strategy = DbStrategy.new id
      success strategy.db_server_info false
    rescue StandardError => error 
      logger.error $! if $!
      logger.error $!.backtrace.join("\n") if $!
      failed error
    end
  end

  # URLに指定された接続先ID/スキーマIDの情報を取得する
  def get
    id = params.require(:con_id)
    sid = params.require(:schema_id)
    begin
      strategy = DbStrategy.new id, sid
      success strategy.schema_info
    rescue StandardError => error 
      logger.error $! if $!
      logger.error $!.backtrace.join("\n") if $!
      failed error
    end
  end

  # URLに指定された接続先ID/スキーマIDへSQLを発行する
  def query
    
  end
  # URLに指定された接続先ID/スキーマIDのダンプを取得する
  def query
    
  end
end
