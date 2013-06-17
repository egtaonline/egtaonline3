class StrategiesController < AuthenticatedController
  expose(:parent) do
    if params["simulator_id"]
      Simulator.find(params["simulator_id"]) 
    elsif params["scheduler_id"]
      Scheduler.find(params["scheduler_id"])
    elsif params["game_id"]
      Game.find(params["game_id"])
    end
  end
  expose(:role){ params["role_id"] }
  
  def create
    parent.add_strategy(role, params["#{role}_strategy"])
    respond_with(parent)
  end
  
  def destroy
    parent.remove_strategy(role, params["id"])
    respond_with(parent)
  end
end