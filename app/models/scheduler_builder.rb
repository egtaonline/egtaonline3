class SchedulerBuilder
  def self.new_scheduler(klass, params, simulator_id, configuration)
    params[:simulator_instance_id] = SimulatorInstance.find_or_create_for(
      simulator_id, configuration).id if params
    scheduler = klass.new(params)
  end

  def self.create(klass, params, simulator_id, configuration)
    scheduler = new_scheduler(klass, params, simulator_id, configuration)
    scheduler.save
    scheduler
  end

  def self.update(scheduler, params, configuration)
    simulator_id = scheduler.simulator_instance.simulator_id
    params[:simulator_instance_id] = SimulatorInstance.find_or_create_for(
      simulator_id, configuration).id if params
    Scheduler.update(scheduler.id, params)
  end
end
