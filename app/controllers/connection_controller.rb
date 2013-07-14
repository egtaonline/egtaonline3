class ConnectionController < AuthenticatedController
  def create
    if Backend.authenticate(params[:connection])
      redirect_to root_url, notice: 'Successfully connected to Flux.'
    else
      flash[:alert] = 'Failed to authenticate.'
      redirect_to new_connection_path
    end
  end
end