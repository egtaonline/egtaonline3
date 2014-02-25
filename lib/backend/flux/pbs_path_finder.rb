class PbsPathFinder
  
  attr_reader :data_path

  def initialize(simulation, simulator, simulators_path, data_path)
    @simulation, @simulator, @simulators_path, @data_path = simulation, simulator, simulators_path, data_path
  end

  def simulator_path
    File.join(@simulators_path, @simulator.fullname, @simulator.name)
  end

  def simulation_path
    File.join(@data_path, @simulation.id.to_s)
  end

  def output_path
    File.join(simulation_path, 'out')
  end

  def error_path
    File.join(simulation_path, 'error')
  end
end