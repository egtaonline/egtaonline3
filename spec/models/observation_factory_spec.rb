require 'spec_helper'

describe ObservationFactory do
  let(:symmetry_groups){ double('Criteria') }
  let(:profile){ double(id: 1, symmetry_groups: symmetry_groups, observations: observations) }
  let(:symmetry_group1){ double(id: 1) }
  let(:symmetry_group2){ double(id: 2) }
  let(:observations){ double('Other Criteria') }
  let(:observation){ double(id: 1, observation_aggs: observation_aggs) }
  let(:observation_aggs){ double('ObservationAgg') }
  let(:players){ double('Player Criteria') }
  subject{ ObservationFactory.new(profile) }

  describe '#add_observation' do
    let(:data) do
      {
        "features" => {
          "featureA" => 34.0,
          "featureB" => [37, 38],
          "featureC" => {
            "C1" => 40.0, "C2" => 42.0
          }
        },
        "symmetry_groups" => [
          {
            "role" => 'Role1',
            "strategy" => 'Strategy1',
            "players" => [
              {
                "payoff" => 2992.73,
      			    "features" => {
      				    "featureA" => 0.001,
      				    "featureB" => [2.0, 2.1]
      			    }
      			  }
            ]
          },
          {
            "role" => 'Role2',
            "strategy" => 'Strategy2',
            "players" => [
              {
                "payoff" => 2929.34
              },
              {
      				  "payoff" => 2000.00
      			  }
            ]
          }
        ]
      }
    end

    before do
      symmetry_groups.stub(:find_by).with(role: 'Role1', strategy: 'Strategy1').and_return(symmetry_group1)
      symmetry_groups.stub(:find_by).with(role: 'Role2', strategy: 'Strategy2').and_return(symmetry_group2)
    end

    it 'creates the observation' do
      observations.should_receive(:create!).with(features: data["features"]).and_return(observation)
      observation_aggs.should_receive(:create!).with(symmetry_group_id: 1)
      observation_aggs.should_receive(:create!).with(symmetry_group_id: 2)
      symmetry_group1.should_receive(:update_attributes!).with(payoff: 2992.73, payoff_sd: nil)
      symmetry_group2.should_receive(:update_attributes!).with(payoff: 2464.67, payoff_sd: 657.142616027907)
      subject.add_observation(data)
    end
  end
end