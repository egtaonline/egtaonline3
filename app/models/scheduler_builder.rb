class SchedulerBuilder
  def self.create(klass, params, simulator_id, configuration)
    params[:simulator_instance_id] = SimulatorInstance.find_or_create_for(simulator_id,
                                        configuration).id if params
    klass.create(params)
  end

  def self.update(scheduler, params, configuration)
    simulator_id = scheduler.simulator_instance.simulator_id
    params[:simulator_instance_id] = SimulatorInstance.find_or_create_for(simulator_id,
                                        configuration).id if params
    Scheduler.update(scheduler.id, params)
  end
end