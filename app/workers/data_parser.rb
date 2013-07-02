class DataParser
  include Sidekiq::Worker

  def perform(simulation_id, location)
    simulation = Simulation.find(simulation_id)
    if simulation.state != 'complete'
      files = Dir.entries(location).keep_if{ |name|
        name =~ /\A(.*)observation(.)*.json\z/ }.collect{ |f|
          location + '/' + f }
      ObservationProcessor.process_files(simulation, files)
    end
  end
end