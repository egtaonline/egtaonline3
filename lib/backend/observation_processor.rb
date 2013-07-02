require_relative 'observation_validator'

class ObservationProcessor
  def self.process_files(simulation, file_paths)
    profile = simulation.profile
    validated = get_validated_data(profile, file_paths)
    unless validated == []
      validated.each { |valid| process_data(profile, valid) }
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

  def self.process_data(profile, data)
    observation = profile.observations.create(features: data["features"])
    if observation.valid?
      data["symmetry_groups"].each do |symmetry_group|
        symmetry_group_id = profile.symmetry_groups.find_by(
          role: symmetry_group["role"], strategy: symmetry_group["strategy"]).id
        symmetry_group["players"].each do |player|
          observation.players.create(symmetry_group_id: symmetry_group_id,
            features: player["features"], payoff: player["payoff"])
        end
      end
    end
  end
end