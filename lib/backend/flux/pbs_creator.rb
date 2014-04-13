require_relative 'pbs_clock_time'
require_relative 'pbs_formatter'
require_relative 'pbs_path_finder'

class PbsCreator
  def initialize(simulators_path, local_data_path, remote_data_path)
    @simulators_path = simulators_path
    @local_data_path = local_data_path
    @remote_data_path = remote_data_path
  end

  def prepare(simulation)
    scheduler = simulation.scheduler
    simulator = scheduler.simulator
    path_finder = PbsPathFinder.new(simulation, simulator, @simulators_path,
                                    @remote_data_path)
    walltime = PbsClockTime.walltime(
      simulation.size * scheduler.time_per_observation)
    document = PbsFormatter.new(
      path_finder, scheduler, simulation, simulator, walltime).format
    File.open("#{@local_data_path}/#{simulation.id}/wrapper", 'w') do |f|
      f.write(document)
    end
  end
end
