require 'spec_helper'

describe Observation do
  # data validation was complex enough that it exists outside of observation
  describe 'create_from_validated_data' do
    let!(:profile){ FactoryGirl.create(:profile, assignment: 'All: 2 A') }
    let(:data) do
      { "features" => { "a" => 2, "b" => 3},
        "symmetry_groups" => [
          { "role" => "All", "strategy" => "A", "players" => [
            { "features" => { "c" => 12, "d" => "true" }, "payoff" => 123 },
            { "features" => { "e" => 23.2 }, "payoff" => 235.2 }
            ]}]}
    end
    it "creates an observation and players from a map of data" do
      observation = Observation.create_from_validated_data(profile, data)
      profile.reload
      profile.observations_count.should == 1
      profile.observations.first.should == observation
      observation.features.should == { "a" => 2, "b" => 3}
      observation.players.count.should == 2
      observation.players.first.features.should == { "c" => 12, "d" => "true" }
      observation.players.first.payoff.should == 123
      observation.players.first.symmetry_group_id.should ==
        profile.symmetry_groups.first.id
      observation.players.last.features.should == { "e" => 23.2 }
      observation.players.last.payoff.should == 235.2
      observation.players.last.symmetry_group_id.should ==
        profile.symmetry_groups.first.id
    end
  end
end
