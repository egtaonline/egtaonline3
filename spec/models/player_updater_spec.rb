require 'spec_helper'

describe PlayerUpdater do
  describe '.update' do
    let!(:instance) { create(:simulator_instance) }
    let!(:matching_profile) do
      create(:profile, :with_observations,
             simulator_instance: instance,
             assignment: 'R1: 1 S1; R2: 1 S2')
    end
    let!(:control_variable) do
      create(:control_variable, :with_role_coefficients,
             simulator_instance: instance)
    end
    let!(:pcv1) do
      PlayerControlVariable.create(
        simulator_instance_id: instance.id, role: 'R1', coefficient: 1,
        expectation: 0.5, name: 'pfeature1')
    end
    let!(:pcv2) do
      PlayerControlVariable.create(
        simulator_instance_id: instance.id, role: 'R2', coefficient: 2,
        expectation: 0.65, name: 'pfeature1')
    end
    context 'when all players have the required features' do
      let!(:non_matching_profile) do
        create(:profile, :with_observations,
               assignment: 'R1: 1 S1; R2: 1 S2')
      end
      before do
        Observation.all.each do |o|
          o.update_attributes(
            features: { "#{control_variable.name}" => 10*rand })
        end
        Player.all.each do |p|
          p.update_attributes(features: { 'pfeature1' => rand })
        end
      end
      it 'updates adjusted payoff of relevant players, leaves others alone' do
        PlayerUpdater.update(instance.id)
        matching_profile.symmetry_groups.each do |s|
          s.players.each do |p|
            pcv = PlayerControlVariable.find_by(role: s.role)
            expect(p.adjusted_payoff).to be_within(0.001).of(
              p.payoff + control_variable.role_coefficients.find_by(
                role: s.role).coefficient * (
                  p.observation.features[control_variable.name].to_f -
                  control_variable.expectation) +
              pcv.coefficient * (p.features[pcv.name].to_f - pcv.expectation))
          end
        end
        non_matching_profile.symmetry_groups.each do |s|
          s.players.each { |p| expect(p.adjusted_payoff).to eq(p.payoff) }
        end
      end
    end
  end
end
