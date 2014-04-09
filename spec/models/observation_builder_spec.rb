require 'spec_helper'

describe ObservationBuilder do
  let(:symmetry_groups){ double('Criteria') }
  let(:profile){ double(id: 1, symmetry_groups: symmetry_groups, observations: observations) }
  let(:symmetry_group1){ double(id: 1, role: 'Role1') }
  let(:symmetry_group2){ double(id: 2, role: 'Role2') }
  let(:observations){ double('Other Criteria') }
  let(:observation){ double(id: 1, observation_aggs: observation_aggs, simulator_instance_id: 1) }
  let(:observation_aggs){ double('ObservationAgg') }
  subject{ ObservationBuilder.new(profile) }

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
      symmetry_groups.stub(:find_by).with(role: 'Role1', strategy: 'Strategy1').and_return(symmetry_group1)
      symmetry_groups.stub(:find_by).with(role: 'Role2', strategy: 'Strategy2').and_return(symmetry_group2)
      criteria1 = double('criteria')
      criteria2 = double('criteria')
      ObservationAgg.should_receive(:where).with(symmetry_group_id: 1).and_return(criteria1)
      ObservationAgg.should_receive(:where).with(symmetry_group_id: 2).and_return(criteria2)
      ordered_criteria1 = double('criteria')
      ordered_criteria2 = double('criteria')
      criteria1.should_receive(:order).with('').and_return(ordered_criteria1)
      criteria2.should_receive(:order).with('').and_return(ordered_criteria2)
      payoff_query1 = [{'payoff' => 2992.73, 'payoff_sd' => nil}]
      payoff_query2 = [{'payoff' => 2464.67, 'payoff_sd' => nil}]
      ordered_criteria1.should_receive(:select).with('avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd').and_return(payoff_query1)
      ordered_criteria2.should_receive(:select).with('avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd').and_return(payoff_query2)
      validated_data['symmetry_groups'].each do |sgroup|
        sgroup['players'].each do |player|
          symmetry_group = sgroup['role'] == 'Role1' ? symmetry_group1 : symmetry_group2
          PlayerBuilder.should_receive(:build).with(observation, symmetry_group, player)
        end
      end
    end


    it 'creates the observation' do
      observations.should_receive(:create!).with(features: validated_data['features'], extended_features: validated_data['extended_features']).and_return(observation)
      observation_aggs.should_receive(:create!).with(symmetry_group_id: 1)
      observation_aggs.should_receive(:create!).with(symmetry_group_id: 2)

      symmetry_group1.should_receive(:update_attributes!).with(payoff: 2992.73, payoff_sd: nil)
      symmetry_group2.should_receive(:update_attributes!).with(payoff: 2464.67, payoff_sd: nil)
      subject.add_observation(validated_data)
    end
  end
end