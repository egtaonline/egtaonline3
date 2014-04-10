require 'spec_helper'

describe PlayerBuilder do
  describe '.build' do
    let(:observation) do
      double(id: 1, features: { 'feature' => '72' }, simulator_instance_id: 1)
    end
    let(:symmetry_group) { double(id: 1, role: 'role') }
    let(:player_data) do
      { 'payoff' => 23, 'features' => { 'first' => 1 },
        'extended_features' => { 'other' => 'false' } }
    end
    let(:cv_query) { double(to_a: []) }
    let(:player_cv_query) { double(to_a: []) }

    it 'builds the player by invoking a control variable calculator' do
      ControlVariable.should_receive(:where).with(
        'simulator_instance_id = ? AND coefficient != 0',
        observation.simulator_instance_id).and_return(cv_query)
      PlayerControlVariable.should_receive(:where).with(
        'simulator_instance_id = ? AND role = ? AND coefficient != 0',
        observation.simulator_instance_id, symmetry_group.role)
          .and_return(player_cv_query)
      CVPayoffAdjuster.should_receive(:adjust).with(
          player_data['payoff'], observation.features, cv_query.to_a,
          player_data['features'], player_cv_query.to_a).and_return(75)
      Player.should_receive(:create!).with(
        observation_id: observation.id, symmetry_group_id: symmetry_group.id,
        payoff: 23, adjusted_payoff: 75, features: { 'first' => 1 },
        extended_features: { 'other' => 'false' })
      PlayerBuilder.build(observation, symmetry_group, player_data)
    end
  end
end
