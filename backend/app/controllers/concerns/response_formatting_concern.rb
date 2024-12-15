module ResponseFormattingConcern
  def success payload
    render json: {:data => payload, :status => :ok}, status: :ok
  end

  def failed error
    Rails.logger.error error
    render json: {
      :error => error.message, 
      :exception => error.message, 
      :traces => {
        "Framework Trace": error.backtrace.map{|e| {:trace => e}}
      }, 
      :status => :internal_server_error, 
      :errors => error
    }, status: :internal_server_error
  end

  def record_not_found error
    render json: {
      :error => :not_found,
      :status => :not_found
    }, status: :not_found
  end

  def invalid_params code, model
    render json: {:data => nil, :status => :bad_request, :errors => {message: code, detail:model.errors}}, status: :bad_request
  end

  def not_found
    render json: {:data => nil, :status => :not_found, :errors => {message: :not_found}}, status: :not_found
  end
end