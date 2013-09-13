class DataParser
  include Sidekiq::Worker
  sidekiq_options queue: 'high_concurrency'

  def perform(simulation_id, location)
    logger.info "Parsing data for #{simulation_id}"
    ActiveRecord::Base.transaction do
      simulation = Simulation.find(simulation_id)
      logger.debug "Simulation #{simulation_id} found"
      if simulation.state != 'complete'
        files = Dir.entries(location).keep_if{ |name| name =~ /\A(.*)observation(.)*.json\z/ }.collect{ |f| location + '/' + f }
        logger.debug "Simulation #{simulation_id} has files: #{files.join(", ")}"
        ObservationProcessor.process_files(simulation, files)
      end
    end
  end
end