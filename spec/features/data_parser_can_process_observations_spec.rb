require 'spec_helper'

describe 'DataParser can process observations' do
  context 'when all of the observations are valid' do
    let!(:profile) do
      create(:profile,
             assignment: 'Buyer: 2 BidValue; Seller: 1 Shade1, 1 Shade2')
    end
    let!(:simulation) do
      create(:simulation, profile: profile, state: 'running')
    end

    it 'creates all the required objects' do
      DataParser.new.perform(
        simulation.id, "#{Rails.root}/spec/support/data/3")
      observations = Observation.all
      expect(observations.count).to eq(2)
      first_observation = observations.first
      expect(first_observation.profile_id).to eq(profile.id)
      expect(first_observation.features).to eq('featureA' => '34')
      expect(first_observation.extended_features)
        .to eq('featureB' => [37, 38],
               'featureC' => { 'subfeature1' => 40, 'subfeature2' => 42 })
      first_symmetry_group = profile.symmetry_groups.find_by(
        role: 'Buyer', strategy: 'BidValue')
      second_symmetry_group = profile.symmetry_groups.find_by(
        role: 'Seller', strategy: 'Shade1')
      third_symmetry_group = profile.symmetry_groups.find_by(
        role: 'Seller', strategy: 'Shade2')
      expect(first_symmetry_group.payoff)
        .to eq((2992.73 + 2990.53 + 2990.73 + 2690.53) / 4.0)
      expect(second_symmetry_group.payoff).to eq((2979.34 + 2929.34) / 2.0)
      expect(third_symmetry_group.payoff).to eq((2924.44 + 2824.44) / 2.0)
      expect(ControlVariable.count).to eq(2)
      expect(ControlVariable.where(
        simulator_instance_id: profile.simulator_instance_id, name: 'featureA')
        .first.role_coefficients.find_by(role: 'Buyer').coefficient).to eq(0)
      expect(ControlVariable.where(
        simulator_instance_id: profile.simulator_instance_id, name: 'featureA')
        .first.role_coefficients.find_by(role: 'Seller').coefficient).to eq(0)
      expect(ControlVariable.where(
        simulator_instance_id: profile.simulator_instance_id, name: 'featureC')
        .count).to eq(1)
      expect(PlayerControlVariable.count).to eq(3)
      expect(PlayerControlVariable.where(
        simulator_instance_id: profile.simulator_instance_id,
        role: 'Buyer', name: 'featureA').first.coefficient).to eq(0)
      expect(PlayerControlVariable.where(
        simulator_instance_id: profile.simulator_instance_id,
        role: 'Seller', name: 'featureA').first.coefficient).to eq(0)
      expect(PlayerControlVariable.where(
        simulator_instance_id: profile.simulator_instance_id,
        role: 'Seller', name: 'featureC').first.coefficient).to eq(0)
    end
  end
end
