class ControlVariablesController < AuthenticatedController
  expose(:control_variables) do
    ControlVariable.where(simulator_instance_id: params[:id])
  end
  expose(:player_control_variables) do
    PlayerControlVariable.where(simulator_instance_id: params[:id])
      .order('role ASC')
  end

  def update
  end
end
