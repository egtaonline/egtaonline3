class RolesController < AuthenticatedController
  expose(:parent) do
    if params["simulator_id"]
      Simulator.find(params["simulator_id"])
    elsif params["scheduler_id"]
      Scheduler.find(params["scheduler_id"])
    elsif params["game_id"]
      Game.find(params["game_id"])
    end
  end

  def create
    if params["role_count"]
      parent.add_role(params["role"], params["role_count"].to_i)
    else
      parent.add_role(params["role"])
    end
    respond_with(parent)
  end

  def destroy
    parent.remove_role(params["role"])
    respond_with(parent)
  end

end