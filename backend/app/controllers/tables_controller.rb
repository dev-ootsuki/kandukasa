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
    id = params[:con_id]
    sid = params[:schema_id]
    tid = params[:table_id]
    conditions = params[:conditions]
    pagination = params[:pagination]
    begin
      strategy = DbStrategy.new id, sid, tid
      success strategy.table_data pagination, conditions
    rescue StandardError => error 
      logger.error $! if $!
      logger.error $!.backtrace.join("\n") if $!
      failed error
    end
  end

  def bulk_truncate
    p params
  end

  def bulk_drop
    
  end

  def bulk_record_delete
    id = params.require(:con_id)
    sid = params.require(:schema_id)
    tid = params.require(:table_id)
    ids = params.require(:keys)
    begin
      strategy = DbStrategy.new id, sid, tid
      success strategy.delete_data ids
    rescue StandardError => error 
      logger.error $! if $!
      logger.error $!.backtrace.join("\n") if $!
      failed error
    end    
  end
end
