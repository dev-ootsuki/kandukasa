class DbConnectionsController < ApplicationController
  include ResponseFormattingConcern
  def show
    begin
      DbConnection.primary{
        success DbConnection.all
      }
    rescue StandardError => error
      failed error
    end
  end

  def get
    begin
      id = params.require(:con_id)
      strategy = DbStrategy.new id
      success strategy.db_server_info true
    rescue ActiveRecord::RecordNotFound => error
      record_not_found error
    rescue StandardError => error
      failed error  
    end
  end

  def create
    con = DbConnection.new(db_connection_permit(params))
    return invalid_params("E-001", con) if con.invalid?
    begin
      DbConnection.primary{
        con.save!
        success con
      }
    rescue StandardError => error
      failed error
    end
  end

  def update
    id = params.require(:con_id)
    raise RecordNotFound.new if DbConnection.find(id).nil?
    
    permit_params = db_connection_permit(params)
    input = DbConnection.new(permit_params)
    return invalid_params("E-001", input) if input.invalid?
    begin
      DbConnection.primary{
        con = DbConnection.find(id)
        DbConnection.transaction do
          con.update! permit_params
        end
        success con
      }
    rescue StandardError => error
      failed error
    end
  end

  def destroy
    id = params.require(:con_id)
    obj = DbConnection.find(id)
    raise RecordNotFound.new if obj.nil? 
    begin
    ret = nil
      DbConnection.primary{
        DbConnection.transaction do
          ret = obj.delete
        end
        success ret
      }
    rescue StandardError => error
      failed error
    end

  end

  private
  def db_connection_permit _param
    return nil if _param[:db_connection].nil?
    _param[:db_connection].delete :created_at
    _param[:db_connection].delete :updated_at
    _param[:db_connection].delete :id
    _param.require(:db_connection).permit(
      :name, :host, :port, :login_name, :db_type, :password, :parameters, :description,
      :timeout, :use_ssl, :ssl_key, :ssl_cert, :ssl_ca, :default_database_name
    )
  end
end
