require_relative 'observation_validator'

class ObservationProcessor
  def self.process_files(simulation, file_paths)
    profile = simulation.profile
    validated = get_validated_data(profile, file_paths)
    unless validated == []
      validated.each do |valid|
        profile.add_observation(valid)
      end
      simulation.finish
    else
      simulation.fail "No valid observations were found."
    end
  end

  private

  def self.get_validated_data(profile, file_paths)
    file_paths.collect do |file_path|
      ObservationValidator.validate(profile, file_path)
    end.compact
  end
end