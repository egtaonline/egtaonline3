require_relative 'pbs_clock_time'
require_relative 'pbs_formatter'
require_relative 'pbs_path_finder'

class PbsCreator
  def initialize(simulators_path, local_data_path, remote_data_path)
    @simulators_path, @local_data_path, @remote_data_path = simulators_path, local_data_path, remote_data_path
  end

  def prepare(simulation)
    scheduler = simulation.scheduler
    simulator = scheduler.simulator
    path_finder = PbsPathFinder.new(simulation, simulator, @simulators_path, @remote_data_path)
    walltime = PbsClockTime.walltime(simulation.size * scheduler.time_per_observation)
    document = PbsFormatter.new(path_finder).format(allocation(simulation), scheduler.nodes,
                                                    scheduler.process_memory, walltime, simulator_tag(simulator),
                                                    simulator.email, simulation.id, simulation.size, extra_args(scheduler))
    File.open("#{@local_data_path}/#{simulation.id}/wrapper", 'w') { |f| f.write(document) }
  end

  def simulator_tag(simulator)
    "egta-#{simulator.name.downcase.gsub(' ', '_')}"
  end

  def allocation(simulation)
    simulation.qos == 'flux' ? 'wellman_flux' : 'engin_flux'
  end

  def extra_args(scheduler)
    scheduler.nodes > 1 ? ' ${PBS_NODEFILE}' : ''
  end
end