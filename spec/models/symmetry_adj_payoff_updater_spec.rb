require 'spec_helper'

describe SymmetryAdjPayoffUpdater do
  describe '.update' do
    let!(:profile) { create(:profile, :with_observations) }
    before do
      ObservationAgg.all.each do |o|
        o.update_attributes(adjusted_payoff: rand)
      end
    end
    it 'updates symmetry groups adjusted payoff statistics' do
      SymmetryAdjPayoffUpdater.update(profile.simulator_instance_id)
      SymmetryGroup.all.each do |s|
        expect(s.adjusted_payoff).to be_within(0.0001).of(
          ObservationAgg.where(symmetry_group_id: s.id)
          .average(:adjusted_payoff))
      end
    end
  end
end
