require 'spec_helper'

describe Game do
  let(:game) { create(:game, size: 2) }
  before do
    game.roles.create(
      name: 'All', count: 2, reduced_count: 2, strategies: %w(A B))
  end

  describe '#add_strategy' do
    it 'adds the strategy to the role' do
      game.add_strategy('All', 'C')
      expect(game.roles.first.strategies).to eq(%w(A B C))
    end

    it 'should not add duplicates' do
      game.add_strategy('All', 'A')
      expect(game.roles.first.strategies).to eq(%w(A B))
    end
  end

  describe '#remove_strategy' do
    it 'removes the strategy from the role' do
      game.remove_strategy('All', 'A')
      expect(game.roles.first.strategies).to eq(%w(B))
    end

    it 'does not remove the strategy from a different role' do
      game.remove_strategy('Fake', 'A')
      expect(game.roles.first.strategies).to eq(%w(A B))
    end
  end

  describe '#invalid_role_partition?' do
    it 'returns false when the role partition is valid' do
      expect(game.invalid_role_partition?).to be_false
    end

    it 'returns true if there are unassigned players' do
      game.remove_role('All')
      game.add_role('All', 1)
      expect(game.invalid_role_partition?).to be_true
    end

    it 'returns true if a role is missing strategies' do
      game.remove_strategy('All', 'A')
      game.remove_strategy('All', 'B')
      expect(game.invalid_role_partition?).to be_true
    end
  end

  describe '#profile_space' do
    it do
      expect(game.profile_space)
        .to eq('((role = \'All\' AND (strategy = \'A\' OR strategy = \'B\')))')
    end
  end

  context 'some profiles' do
    let!(:profile) do
      create(:profile, :with_observations,
             simulator_instance: game.simulator_instance,
             assignment: 'All: 2 A')
    end
    let!(:profile2) do
      create(:profile,
             simulator_instance: game.simulator_instance,
             assignment: 'All: 1 A, 1 B')
    end
    let!(:profile3) do
      create(:profile, :with_observations,
             simulator_instance: game.simulator_instance,
             assignment: 'All: 2 C')
    end
    let!(:profile4) do
      create(:profile, :with_observations,
             assignment: 'All: 2 B')
    end
    let!(:profile5) do
      create(:profile, :with_observations,
             simulator_instance: game.simulator_instance,
             assignment: 'All: 3 B')
    end

    describe '#profile_counts' do
      before do
        ObservationBuilder.new(profile).add_observation(
          'features' => {}, 'symmetry_groups' => [
            { 'role' => 'All', 'strategy' => 'A', 'players' => [
              { 'features' => {}, 'payoff' => 200 },
              { 'features' => {}, 'payoff' => 300 }
            ] }
          ])
      end

      it 'only counts profiles and observations from its profiles' do
        profile_counts = game.profile_counts
        expect(profile_counts['count'].to_i).to eq(1)
        expect(profile_counts['observations_count'].to_i).to eq(2)
      end
    end
  end
end
