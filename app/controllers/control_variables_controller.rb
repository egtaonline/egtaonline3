class ControlVariablesController < AuthenticatedController
  expose(:control_variables) do
    ControlVariable.where(simulator_instance_id: params[:id])
  end
  expose(:player_control_variables) do
    PlayerControlVariable.where(simulator_instance_id: params[:id])
      .order('role ASC')
  end

  def update
    ControlVariateUpdater.perform_async(
      params[:id], params[:control_variables].values,
      params[:player_control_variables].values)
    respond_with(Game.find(params[:game_id]))
  end
end
