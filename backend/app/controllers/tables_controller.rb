class TablesController < ApplicationController
  include ResponseFormattingConcern

  def get
    id = params.require(:con_id)
    sid = params.require(:schema_id)
    tid = params.require(:table_id)
    begin
      strategy = DbStrategy.new id, sid, tid
      success strategy.table_info
    rescue StandardError => error 
      logger.error $! if $!
      logger.error $!.backtrace.join("\n") if $!
      failed error
    end
  end

  # URLに指定された接続先ID/スキーマIDに所属するテーブルの一覧を取得する
  def index
    
  end

  # URLに指定された接続先ID/スキーマID/テーブルIDの情報を取得する
  def show
    
  end

  # URLに指定された接続先ID/スキーマIDに所属するテーブルに対して検索を行う
  def query
    id = params.require(:con_id)
    sid = params.require(:schema_id)
    tid = params.require(:table_id)
    begin
      strategy = DbStrategy.new id, sid, tid
      success strategy.table_data nil
    rescue StandardError => error 
      logger.error $! if $!
      logger.error $!.backtrace.join("\n") if $!
      failed error
    end
  end
end
