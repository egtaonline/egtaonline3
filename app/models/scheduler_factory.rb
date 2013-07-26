class SchedulerFactory
  def self.create(klass, params, simulator_id, configuration)
    params[:simulator_instance_id] = get_simulator_instance_id(simulator_id, configuration) if params
    klass.create(params)
  end

  def self.update(scheduler, params, configuration)
    params[:simulator_instance_id] = get_simulator_instance_id(scheduler.simulator_instance.simulator_id, configuration) if params
    Scheduler.update(scheduler.id, params)
  end

  private

  # If find_or_create_by works, use that instead
  def self.get_simulator_instance_id(simulator_id, configuration)
    configuration ||= {}
    simulator_instance = SimulatorInstance.where("simulator_id = ? AND configuration @> (?)", simulator_id, configuration.collect{ |key, value| "\"#{key}\" => \"#{value}\"" }.join(", ")).first
    simulator_instance ||= SimulatorInstance.create!(simulator_id: simulator_id, configuration: configuration)
    simulator_instance.id
  end
end