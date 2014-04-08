class PlayerBuilder
  def self.build(observation, symmetry_group, player_data)
    observation_cvs = ControlVariable.where('simulator_instance_id = ? AND coefficient != 0', observation.simulator_instance_id).to_a
    player_cvs = PlayerControlVariable.where('simulator_instance_id = ? AND role = ? AND coefficient != 0',
        observation.simulator_instance_id, symmetry_group.role).to_a
    adjusted_payoff = CVPayoffAdjuster.adjust(player_data["payoff"], observation.features, observation_cvs,
          player_data["features"], player_cvs)
    Player.create!(observation_id: observation.id, symmetry_group_id: symmetry_group.id,
                   payoff: player_data["payoff"], adjusted_payoff: adjusted_payoff,
                   features: player_data["features"], extended_features: player_data["extended_features"])
  end
end