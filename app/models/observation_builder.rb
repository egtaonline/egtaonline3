class ObservationBuilder
  def initialize(profile)
    @profile = profile
  end

  def add_observation(data)
    ActiveRecord::Base.transaction do
      observation = @profile.observations.create!(
        features: data['features'],
        extended_features: data['extended_features'])
      players = []
      data['symmetry_groups'].each do |symmetry_group|
        players << players_for_symmetry_group(observation, symmetry_group)
      end
      Player.import(players.flatten)
      observation
    end
  end

  private

  def players_for_symmetry_group(observation, data)
    sgroup = @profile.symmetry_groups.find_by(
      role: data['role'], strategy: data['strategy'])
    data['players'].map do |player|
      PlayerBuilder.build(observation, sgroup, player)
    end
  end
end
