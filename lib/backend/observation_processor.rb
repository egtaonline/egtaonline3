require_relative 'observation_validator'

class ObservationProcessor
  def self.process_files(simulation, file_paths)
    profile = simulation.profile
    validated = get_validated_data(profile, file_paths)
    unless validated == []
      logger.debug "Simulation #{simulation.id} had the following valid files: #{validated.join(", ")}"
      validated.each do |valid|
        profile.add_observation(valid)
      end
      logger.info "Finishing simulation #{simulation.id}"
      simulation.finish
    else
      logger.debug "Simulation #{simulation.id} had no valid files"
      simulation.fail "No valid observations were found."
    end
  end

  private

  def self.get_validated_data(profile, file_paths)
    file_paths.collect{ |file_path| ObservationValidator.validate(profile, file_path) }.compact
  end
end