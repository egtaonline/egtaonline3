require 'spec_helper'

describe ObservationAgg do
  describe 'creation' do
    let(:profile) { create(:profile, assignment: 'A: 1 B, 2 C; D: 2 E') }
    it 'sets the payoff and payoff_sd' do
      observation = ObservationBuilder.new(profile).add_observation(
        'features' => {},
        'symmetry_groups' => [
          { 'role' => 'A', 'strategy' => 'B', 'players' => [
            { 'payoff' => 12, 'features' => {} }
          ] },
          { 'role' => 'A', 'strategy' => 'C', 'players' => [
            { 'payoff' => 14, 'features' => {} },
            { 'payoff' => 16, 'features' => {} }
          ] },
          { 'role' => 'D', 'strategy' => 'E', 'players' => [
            { 'payoff' => 15, 'features' => {} },
            { 'payoff' => 17, 'features' => {} }
          ] }
        ])
      AggregateUpdater.update([observation], profile)
      first_id = profile.symmetry_groups.find_by(role: 'A', strategy: 'B').id
      second_id = profile.symmetry_groups.find_by(role: 'A', strategy: 'C').id
      third_id = profile.symmetry_groups.find_by(role: 'D', strategy: 'E').id
      expect(ObservationAgg.count).to eq(3)
      first_agg = ObservationAgg.find_by(symmetry_group_id: first_id)
      expect(first_agg.payoff).to eq(12)
      expect(first_agg.payoff_sd).to eq(nil)
      second_agg = ObservationAgg.find_by(symmetry_group_id: second_id)
      expect(second_agg.payoff).to eq(15)
      second_agg.payoff_sd.should be_within(0.001).of(Math.sqrt(2))
      third_agg = ObservationAgg.find_by(symmetry_group_id: third_id)
      expect(third_agg.payoff).to eq(16)
      third_agg.payoff_sd.should be_within(0.001).of(Math.sqrt(2))
    end
  end
end
