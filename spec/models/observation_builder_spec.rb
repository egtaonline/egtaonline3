require 'spec_helper'

describe ObservationBuilder do
  let(:symmetry_groups) { double('Criteria') }
  let(:cv_state) { double(state: 'none') }
  let(:simulator_instance) { double(control_variate_state: cv_state) }
  let(:profile) do
    double(id: 1, symmetry_groups: symmetry_groups, observations: observations,
           simulator_instance: simulator_instance)
  end
  let(:symmetry_group1) { double(id: 1, role: 'Role1', count: 1) }
  let(:symmetry_group2) { double(id: 2, role: 'Role2', count: 2) }
  let(:observations) { double('Other Criteria') }
  let(:observation) { double(id: 1, simulator_instance_id: 1) }
  let(:player){ double('player') }
  subject { ObservationBuilder.new(profile) }

  describe '#add_observation' do
    let(:validated_data) do
      {
        'features' => { 'featureA' => 34.0 },
        'extended_features' => {
          'featureB' => [37, 38],
          'featureC' => {
            'C1' => 40.0, 'C2' => 42.0
          }
        },
        'symmetry_groups' => [
          {
            'role' => 'Role1',
            'strategy' => 'Strategy1',
            'players' => [
              {
                'payoff' => 2992.73,
                'features' => {
                  'featureA' => 0.001
                },
                'extended_features' => {
                  'featureB' => [2.0, 2.1]
                }
              }
            ]
          },
          {
            'role' => 'Role2',
            'strategy' => 'Strategy2',
            'players' => [
              {
                'payoff' => 2929.34
              },
              {
                'payoff' => 2000.00
              }
            ]
          }
        ]
      }
    end

    # temporarily ugly
    before do
      symmetry_groups.stub(:find_by).with(role: 'Role1', strategy: 'Strategy1')
        .and_return(symmetry_group1)
      symmetry_groups.stub(:find_by).with(role: 'Role2', strategy: 'Strategy2')
        .and_return(symmetry_group2)
    end

    it 'creates the observation' do
      player_builder = double(build: player)
      PlayerBuilder.stub(:new).and_return(player_builder)
      observations.should_receive(:create!).with(
        features: validated_data['features'],
        extended_features: validated_data['extended_features'])
          .and_return(observation)
      player_builder.stub(:build).and_return(player)
      Player.should_receive(:import).with([player, player, player])
      subject.add_observation(validated_data)
    end
  end
end
