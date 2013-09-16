class ObservationProcessor
  def initialize(simulation, file_paths, observation_validator = ObservationValidator.new(simulation.profile), observation_factory = ObservationFactory.new(simulation.profile))
    @simulation = simulation
    @file_paths = file_paths
    @observation_validator = observation_validator
    @observation_factory = observation_factory
  end

  def process_files
    validated = get_validated_data
    unless validated == []
      process_observations(validated)
      @simulation.finish
    else
      @simulation.fail "No valid observations were found."
    end
  end

  private

  def process_observations(validated)
    validated.each do |data|
      @observation_factory.add_observation(data)
    end
  end

  def get_validated_data
    @file_paths.collect{ |file_path| @observation_validator.validate(file_path) }.compact
  end
end