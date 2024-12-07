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
      failed error
    end
  end

  # URLに指定された接続先ID/スキーマIDに所属するテーブルに対して検索を行う
  def query
    id = params.require(:con_id)
    sid = params.require(:schema_id)
    tid = params.require(:table_id)
    conditions = params.require(:dbdata).permit(conditions: [:operator, :column, input:[]])
    conditions = conditions["conditions"]
    pagination = params.require(:pagination).permit(:page, :descending, :rowsNumber, :rowsPerPage, :sortBy)
    andor = params.require(:andor)
    begin
      strategy = DbStrategy.new id, sid, tid
      success strategy.table_data pagination, conditions, andor
    rescue StandardError => error 
      failed error
    end
  end

  def create_data
    id = params.require(:con_id)
    sid = params.require(:schema_id)
    tid = params.require(:table_id)
    begin
      strategy = DbStrategy.new id, sid, tid
      columns = strategy.table_columns
      perm_targets = columns.map{|e| e["column_name"].to_sym}
      dbdata = params.require(:data).permit(perm_targets)
      success strategy.create_table_data dbdata, columns
    rescue StandardError => error 
      failed error
    end    
  end

  def update_data
    
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
      failed error
    end    
  end
end
