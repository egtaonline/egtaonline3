require 'spec_helper'

describe ObservationAggsUpdater do
  describe '.update' do
    let!(:profile) do
      create(:profile, :with_observations, assignment: 'R1: 2 S1; R2: 2 S2')
    end
    before do
      Player.all.each do |p|
        p.update_attributes(adjusted_payoff: rand)
      end
    end
    it 'updates the adjusted payoff for relevant observation aggs' do
      ObservationAggsUpdater.update(profile.simulator_instance_id)
      ObservationAgg.all.each do |o|
        expect(o.adjusted_payoff).to be_within(0.0001).of(Player.where(
          symmetry_group_id: o.symmetry_group_id,
          observation_id: o.observation_id).average(:adjusted_payoff))
      end
    end
  end
end
