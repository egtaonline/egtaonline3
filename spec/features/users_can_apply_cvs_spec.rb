require 'spec_helper'

describe 'users can apply control variates from the game page' do
  let!(:game) { create(:game) }

  before do
    sign_in
  end

  describe 'visiting the games page gives link to editing control variates' do
    it 'directs to the correct page when you click the link' do
      visit "/games/#{game.id}"
      click_on 'Set Control Variates'
      expect(page).to have_content 'Edit Control Variables'
      expect(page).to have_content 'Player-Level Control Variables'
    end
  end

  describe 'updating the control variables updates payoff adjustments' do
    let!(:profile1) do
      create(:profile, :with_observations,
             simulator_instance: game.simulator_instance,
             assignment: 'R1: 1 S1; R2: 1 S2')
    end
    let!(:profile2) do
      create(:profile, :with_observations,
             simulator_instance: game.simulator_instance,
             assignment: 'R1: 1 S1; R2: 1 S3')
    end
    let!(:control_variable) do
      ControlVariable.create!(
        simulator_instance_id: game.simulator_instance_id,
        name: 'feature1', expectation: 0.5)
    end
    let!(:pcontrol_variable1) do
      PlayerControlVariable.create!(
        simulator_instance_id: game.simulator_instance_id, role: 'R1',
        name: 'pfeature1', expectation: 0.4)
    end
    let!(:pcontrol_variable2) do
      PlayerControlVariable.create!(
        simulator_instance_id: game.simulator_instance_id, role: 'R2',
        name: 'pfeature2', expectation: 0.6)
    end

    before do
      control_variable.role_coefficients.create(role: 'R1')
      control_variable.role_coefficients.create(role: 'R2')
      [profile1, profile2].each do |profile|
        profile.observations.each do |observation|
          observation.update_attributes(
            features: { 'feature1' => "#{20*rand}" })
          observation.players.each do |player|
            if player.symmetry_group.role == 'R1'
              player.update_attributes(
                features: { 'pfeature1' => "#{20*rand}" })
            else
              player.update_attributes(
                features: { 'pfeature2' => "#{20*rand}" })
            end
          end
        end
      end
    end

    it 'performs the correct payoff adjustments' do
      visit "games/#{game.id}"
      click_on 'Set Control Variates'
      fill_in 'control_variables[1][role_coefficients][1][coefficient]',
              with: 0.6
      fill_in 'control_variables[1][role_coefficients][2][coefficient]',
              with: 0.7
      fill_in 'player_control_variables_1_coefficient', with: 0.3
      fill_in 'player_control_variables_2_coefficient', with: -0.4
      click_on 'Apply Control Variate Adjustments to Payoffs'
      expect(page).to have_content('Control variates applied at: ')
      [profile1, profile2].each do |profile|
        profile.symmetry_groups.each do |sgroup|
          sgroup.players.each do |p|
            if sgroup.role == 'R1'
              expect(p.adjusted_payoff).to be_within(0.001).of(
                p.payoff +
                0.6 * (Float(p.observation.features['feature1']) - 0.5) +
                0.3 * (Float(p.features['pfeature1']) - 0.4))
            else
              expect(p.adjusted_payoff).to be_within(0.001).of(
                p.payoff +
                0.7 * (Float(p.observation.features['feature1']) - 0.5) -
                0.4 * (Float(p.features['pfeature2']) - 0.6))
            end
          end
        end
      end
    end
  end
end
