class ControlVariablesController < AuthenticatedController
  expose(:control_variables) { ControlVariable.where(simulator_instance_id: params[:id]) }
  expose(:player_control_variables) { PlayerControlVariable.where(simulator_instance_id: params[:id]).order('role ASC') }

  def update

  end
end