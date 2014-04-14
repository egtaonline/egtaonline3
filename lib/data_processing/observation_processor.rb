class ObservationProcessor
  def initialize(
        simulation, file_paths,
        observation_validator = ObservationValidator.new(simulation.profile),
        observation_builder = ObservationBuilder.new(simulation.profile),
        cv_builder = ControlVariableBuilder.new(
          simulation.profile.simulator_instance))
    @simulation = simulation
    @file_paths = file_paths
    @observation_validator = observation_validator
    @observation_builder = observation_builder
    @cv_builder = cv_builder
  end

  def process_files
    validated = validated_data
    if validated == []
      @simulation.fail 'No valid observations were found.'
    else
      process_observations(validated)
      @simulation.finish
    end
  end

  private

  def process_observations(validated)
    observations = []
    validated.each do |data|
      @cv_builder.extract_control_variables(data)
      observations << @observation_builder.add_observation(data)
    end
    AggregateUpdater.update(
      observations, @simulation.profile) unless observations == []
  end

  def validated_data
    @file_paths.map { |path| @observation_validator.validate(path) }.compact
  end
end
