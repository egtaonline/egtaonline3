require 'spec_helper'

describe PlayerBuilder do
  describe '.build' do
    let(:symmetry_group) { double(id: 1, role: 'role') }
    let(:criteria) { double('Criteria') }
    let(:profile) { double(symmetry_groups: criteria) }
    let(:observation) do
      double(id: 1, features: { 'feature' => '72' }, simulator_instance_id: 1,
             profile: profile)
    end
    let(:player_data) do
      { 'payoff' => 23, 'features' => { 'first' => 1 },
        'extended_features' => { 'other' => 'false' } }
    end
    let(:cv_query) { double(to_a: []) }
    let(:player_cv_query) { double(to_a: []) }

    it 'builds the player by invoking a control variable calculator' do
      criteria.should_receive(:pluck).with(:role).and_return(['role'])
      joined = double('criteria')
      ControlVariable.should_receive(:joins).with(:role_coefficients)
        .and_return(joined)
      joined.should_receive(:where).with(
        'simulator_instance_id = ? AND role = ? AND coefficient != 0',
        observation.simulator_instance_id, symmetry_group.role)
        .and_return(cv_query)
      PlayerControlVariable.should_receive(:where).with(
        'simulator_instance_id = ? AND role = ? AND coefficient != 0',
        observation.simulator_instance_id, symmetry_group.role)
          .and_return(player_cv_query)
      CVPayoffAdjuster.should_receive(:adjust).with(
          player_data['payoff'], observation.features, cv_query.to_a,
          player_data['features'], player_cv_query.to_a).and_return(75)

      player_builder = PlayerBuilder.new(observation, 'applying')
      player = player_builder.build(symmetry_group, player_data)
      expect(player.observation_id).to eq(observation.id)
      expect(player.symmetry_group_id).to eq(symmetry_group.id)
      expect(player.payoff).to eq(23)
      expect(player.adjusted_payoff).to eq(75)
      expect(player.features).to eq('first' => 1)
      expect(player.extended_features).to eq('other' => 'false')
    end

    it 'skips cv stuff if the state is none' do
      player_builder = PlayerBuilder.new(observation, 'none')
      player = player_builder.build(symmetry_group, player_data)
      expect(player.payoff).to eq(23)
      expect(player.adjusted_payoff).to eq(23)
    end
  end
end
