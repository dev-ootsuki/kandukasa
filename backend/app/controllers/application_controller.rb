class ApplicationController < ActionController::API
  before_action :establish_primary
  after_action :establish_primary

  def establish_primary
    DbConnection.primary
  end

end
