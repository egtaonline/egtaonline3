class RolesController < AuthenticatedController
  expose(:parent) do
    if params['simulator_id']
      Simulator.find(params['simulator_id'])
    elsif params['scheduler_id']
      Scheduler.find(params['scheduler_id'])
    elsif params['game_id']
      Game.find(params['game_id'])
    end
  end
  expose(:role) { params['id'] }

  def create
    if params['role_count']
      params['reduced_count'] ||= params['role_count']
      parent.add_role(params['role'], params['role_count'].to_i,
                      params['reduced_count'].to_i)
    else
      parent.add_role(params['role'])
    end
    respond_with(parent)
  end

  def destroy
    parent.remove_role(role)
    respond_with(parent)
  end

  def add_strategy
    parent.add_strategy(role, params["#{role}_strategy"])
    respond_with(parent)
  end

  def remove_strategy
    parent.remove_strategy(role, params['strategy'])
    respond_with(parent)
  end

  def add_deviating_strategy
    parent.add_deviating_strategy(role, params["deviating_#{role}_strategy"])
    respond_with(parent)
  end

  def remove_deviating_strategy
    parent.remove_deviating_strategy(role, params['strategy'])
    respond_with(parent)
  end
end
