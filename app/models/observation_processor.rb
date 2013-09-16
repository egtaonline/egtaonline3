class ObservationProcessor
  def initialize(simulation, file_paths, observation_validator = ObservationValidator.new(simulation.profile))
    @simulation = simulation
    @profile = simulation.profile
    @file_paths = file_paths
    @observation_validator = observation_validator
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
    validated.each do |valid|
      @profile.add_observation(valid)
    end
  end

  def get_validated_data
    @file_paths.collect{ |file_path| @observation_validator.validate(file_path) }.compact
  end
end