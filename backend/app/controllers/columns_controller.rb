class ColumnsController < ApplicationController
  include ResponseFormattingConcern

  def destroy
    id = params.require(:con_id)
    sid = params.require(:schema_id)
    tid = params.require(:table_id)
    cid = params.require(:column_id)
    begin
      strategy = DbStrategy.new id, sid, tid, cid
      success strategy.delete_column
    rescue StandardError => error 
      failed error
    end    
  end
end
