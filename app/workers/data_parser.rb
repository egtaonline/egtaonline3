class DataParser
  include Sidekiq::Worker
  sidekiq_options queue: 'high_concurrency'

  def perform(simulation_id, location)
    simulation = Simulation.find(simulation_id)
    unless simulation.state == 'complete'
      files = Dir.entries(location).keep_if do |name|
        name =~ /\A(.*)observation(.)*.json\z/
      end
      files = files.map { |f| location + '/' + f }
      ObservationProcessor.new(simulation, files).process_files
    end
  end
end
