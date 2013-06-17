class ProfileSpacesController < AuthenticatedController
  def update_configuration
    @simulator = Simulator.find(params[:simulator_id])
    respond_to do |format|
      format.js { render "configuration/update_configuration" }
    end
  end
end