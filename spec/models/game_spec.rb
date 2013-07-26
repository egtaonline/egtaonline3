require 'spec_helper'

describe Game do
  let(:game){ FactoryGirl.create(:game, size: 2) }
  before do
    game.roles.create(name: 'All', count: 2, reduced_count: 2,
      strategies: ['A', 'B'])
  end

  describe '#add_strategy' do
    it "adds the strategy to the role" do
      game.add_strategy('All', 'C')
      game.roles.first.strategies.should == ['A', 'B', 'C']
    end

    it 'should not add duplicates' do
      game.add_strategy('All', 'A')
      game.roles.first.strategies.should == ['A', 'B']
    end
  end

  describe '#remove_strategy' do
    it 'removes the strategy from the role' do
      game.remove_strategy('All', 'A')
      game.roles.first.strategies.should == ['B']
    end

    it 'does not remove the strategy from a different role' do
      game.remove_strategy('Fake', 'A')
      game.roles.first.strategies.should == ['A', 'B']
    end
  end

  describe '#invalid_role_partition?' do
    it 'returns false when the role partition is valid' do
      game.invalid_role_partition?.should == false
    end

    it 'returns true if there are unassigned players' do
      game.remove_role('All')
      game.add_role('All', 1)
      game.invalid_role_partition?.should == true
    end

    it 'returns true if a role is missing strategies' do
      game.remove_strategy('All', 'A')
      game.remove_strategy('All', 'B')
      game.invalid_role_partition?.should == true
    end
  end

  describe '#profile_space' do
    it { game.profile_space.should == "All: \\d+ (A(, \\d+ )?)*(B(, \\d+ )?)*" }
  end

  context 'some profiles' do
    let!(:profile) do
      FactoryGirl.create(:profile, :with_observations,
      simulator_instance: game.simulator_instance,
      assignment: 'All: 2 A')
    end
    let!(:profile2) do
      FactoryGirl.create(:profile,
      simulator_instance: game.simulator_instance,
      assignment: 'All: 1 A, 1 B')
    end
    let!(:profile3) do
      FactoryGirl.create(:profile, :with_observations,
      simulator_instance: game.simulator_instance,
      assignment: 'All: 2 C')
    end
    let!(:profile4) do
      FactoryGirl.create(:profile, :with_observations,
      assignment: 'All: 2 B')
    end
    let!(:profile5) do
      FactoryGirl.create(:profile, :with_observations,
      simulator_instance: game.simulator_instance,
      assignment: 'All: 3 B')
    end

    describe '#profile_count' do
      it "only counts the profiles that match and have observations" do
        game.profile_count.should == 1
      end
    end

    describe '#observation_count' do
      before do
        Observation.create_from_validated_data(profile,
          { "features" => {}, "symmetry_groups" => [{ "role" => "All",
            "strategy" => "A", "players" => [{ "features" => {},
            "payoff" => 200}, { "features" => {}, "payoff" => 300 }]}]})
      end

      it "only counts observations from its profiles" do
        game.observation_count.should == 2
      end
    end
  end
end
