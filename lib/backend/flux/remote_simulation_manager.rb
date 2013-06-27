require_relative 'flux_policy'
require_relative 'pbs_creator'
require_relative 'simulation_submitter'
require_relative 'simulation_status_monitor'

class RemoteSimulationManager
  def initialize(options)
    @flux_policy = FluxPolicy.new(options[:flux_active_limit])
    @connection = options[:connection]
    @local_path = options[:local_data_path]
    @pbs_creator = PbsCreator.new(options[:simulators_path], @local_path, options[:remote_data_path])
    @simulation_submitter = SimulationSubmitter.new(options[:remote_data_path])
    @status_monitor = SimulationStatusMonitor.new(@local_path)
  end

  def prepare_simulation(simulation)
    simulation = @flux_policy.set_queue(simulation)
    @pbs_creator.prepare(simulation)
  end

  def schedule_simulation(simulation)
    @simulation_submitter.submit(@connection, simulation)
  end

  def update_simulations
    @status_monitor.update_simulations(@connection)
  end

  def clean_simulation(simulation_number)
    FileUtils.rm_rf "#{@local_path}/#{simulation_number}"
  end
end