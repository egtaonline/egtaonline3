require 'spec_helper'

describe 'missing adjusted payoffs' do
  describe 'when creating an observation_agg and missing adjusted payoffs' do
    it 'updates the old observation_aggs before calculating statistcs' do
      profile = create(:profile, :with_observations)
      profile.symmetry_groups.each do |sgroup|
        sgroup.update_attributes(adjusted_payoff: nil, adj_sum_sq_diff: nil)
        sgroup.observation_aggs.each do |agg|
          agg.update_attributes(adjusted_payoff: nil)
        end
      end
      observation = ObservationBuilder.new(profile).add_observation(
        'features' => {},
        'symmetry_groups' => profile.symmetry_groups.map do |s|
          { 'role' => s.role, 'strategy' => s.strategy,
            'players' => Array.new(s.count) do
              { 'features' => {}, 'payoff' => 110 }
            end
          }
        end)
      AggregateManager.create_aggregates([observation], profile)
      profile.reload
      profile.symmetry_groups.each do |s|
        expect(s.adjusted_payoff).to eq(105)
        expect(s.observation_aggs.first.adjusted_payoff).to eq(100)
        expect(s.adj_sum_sq_diff).to eq(50)
      end
    end
  end
end
