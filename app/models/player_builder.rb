class PlayerBuilder
  def initialize(observation, state)
    @state = state
    unless state == 'none'
      @observation_cvs = {}
      @player_cvs = {}
      observation.profile.symmetry_groups.pluck(:role).uniq.each do |role|
        @observation_cvs[role] = ControlVariable.joins(:role_coefficients)
          .where('simulator_instance_id = ? AND role = ? AND coefficient != 0',
          observation.simulator_instance_id, role).to_a
        @player_cvs[role] = PlayerControlVariable.where(
          'simulator_instance_id = ? AND role = ? AND coefficient != 0',
          observation.simulator_instance_id, role).to_a
      end
    end
    @observation = observation
  end

  def build(symmetry_group, player_data)
    if @state == 'none'
      adjusted_payoff = player_data['payoff']
    else
      role = symmetry_group.role
      adjusted_payoff = CVPayoffAdjuster.adjust(
        player_data['payoff'], @observation.features, @observation_cvs[role],
        player_data['features'], @player_cvs[role])
    end
    Player.new(observation_id: @observation.id,
               symmetry_group_id: symmetry_group.id,
               payoff: player_data['payoff'],
               adjusted_payoff: adjusted_payoff,
               features: player_data['features'],
               extended_features: player_data['extended_features'])
  end
end
