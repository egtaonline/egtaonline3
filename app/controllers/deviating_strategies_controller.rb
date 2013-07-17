class DeviatingStrategiesController < AuthenticatedController
  expose(:parent){ Scheduler.find(params["scheduler_id"]) }
  expose(:role){ params["role_id"] }

  def create
    parent.add_deviating_strategy(role, params["deviating_#{role}_strategy"])
    respond_with(parent)
  end

  def destroy
    parent.remove_deviating_strategy(role, params["id"])
    respond_with(parent)
  end
end