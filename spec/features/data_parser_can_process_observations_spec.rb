require 'spec_helper'

describe "DataParser can process observations" do
  context "when all of the observations are valid" do
    let(:profile) do
      FactoryGirl.create(:profile,
        assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2')
    end
    let(:simulation) do
      FactoryGirl.create(:simulation, profile: profile, state: 'running')
    end

    it "creates all the required objects" do
      DataParser.new.perform(simulation.id, "#{Rails.root}/spec/support/data/3")
      observations = Observation.all
      observations.count.should == 2
      first_observation, second_observation = observations.to_a
      first_observation.profile_id.should == profile.id
      first_observation.features.should == {"featureA" => 34,
        "featureB" => [37, 38], "featureC" => {
  			  "subfeature1" => 40, "subfeature2" => 42 } }
  		first_symmetry_group = profile.symmetry_groups.find_by(
      	role: 'Buyer', strategy: 'BidValue')
      second_symmetry_group = profile.symmetry_groups.find_by(
        role: 'Seller', strategy: 'Shade1')
      third_symmetry_group = profile.symmetry_groups.find_by(
        role: 'Seller', strategy: 'Shade2')
  		player1, player2, player3, player4 = first_observation.players.to_a
  		player1.features.should == { "featureA" => 0.001,
				"featureB" => [2.0, 2.1] }
			player2.features.should == { "featureA" => 0.002,
				"featureB" => [2.0, 2.1] }
			player3.features.should == { "featureA" => 0.003,
				"featureB" => [1.4, 1.7] }
			player4.features.should == { "featureA" => 0.003,
				"featureB" => [1.3, 1.7] }
			first_symmetry_group.payoff.should ==
			  (2992.73+2990.53+2990.73+2690.53)/4.0
			second_symmetry_group.payoff.should ==
			  (2979.34+2929.34)/2.0
			third_symmetry_group.payoff.should ==
			  (2924.44+2824.44)/2.0
    end
  end
end