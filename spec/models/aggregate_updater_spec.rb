require 'spec_helper'

describe AggregateManager do
  describe '.update' do
    let(:profile){ create(:profile) }
    let(:observation){ Observation.create(profile_id: profile.id) }

    before do
      profile.symmetry_groups.each do |s|
        s.count.times do
          Player.create(observation_id: observation.id,
                        symmetry_group_id: s.id, payoff: rand)
        end
      end
    end

    it 'creates ObservationAggs and updates symmetry groups to agg the aggs' do
      AggregateManager.create_aggregates([observation], profile)
      expect(ObservationAgg.count).to eq(profile.symmetry_groups.count)
      profile.reload.symmetry_groups.each do |s|
        expect(s.payoff)
          .to eq(ObservationAgg.where(symmetry_group_id: s.id).first.payoff)
        expect(s.payoff_sd).to be nil
      end
    end
  end
end
