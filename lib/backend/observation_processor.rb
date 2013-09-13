require_relative 'observation_validator'

class ObservationProcessor
  def self.process_files(simulation, file_paths)
    profile = simulation.profile
    validated = get_validated_data(profile, file_paths)
    unless validated == []
      puts "Simulation #{simulation.id} had #{validated.size} valid file(s)"
      validated.each do |valid|
        profile.add_observation(valid)
      end
      puts "Finishing simulation #{simulation.id}"
      simulation.finish
    else
      puts "Simulation #{simulation.id} had no valid files"
      simulation.fail "No valid observations were found."
    end
  end

  private

  def self.get_validated_data(profile, file_paths)
    file_paths.collect{ |file_path| ObservationValidator.validate(profile, file_path) }.compact
  end
end