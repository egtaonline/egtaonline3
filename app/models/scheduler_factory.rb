class SchedulerFactory
  def self.create(klass, params)
    if params
      simulator_id = params.delete(:simulator_id)
      configuration = params.delete(:configuration)
      params[:simulator_instance_id] = get_simulator_instance_id(simulator_id, configuration)
    end
    klass.create(params)
  end

  def self.update(scheduler, params)
    if params
      configuration = params.delete(:configuration)
      params[:simulator_instance_id] = get_simulator_instance_id(scheduler.simulator_instance.simulator_id, configuration)
    end
    Scheduler.update(scheduler.id, params)
  end

  private

  # If find_or_create_by works, use that instead
  def self.get_simulator_instance_id(simulator_id, configuration)
    simulator_instance = SimulatorInstance.where("simulator_id = ? AND configuration @> hstore(ARRAY[?])", simulator_id, configuration.to_a.flatten).first
    simulator_instance ||= SimulatorInstance.create!(simulator_id: simulator_id, configuration: configuration)
    simulator_instance.id
  end
end