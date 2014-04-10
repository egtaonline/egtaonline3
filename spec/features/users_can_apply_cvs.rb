require 'spec_helper'

describe 'users can apply control variates from the game page' do
  let(:game) { create(:game) }

  before do
    sign_in
  end

  describe 'visiting the games page gives link to editing control variates' do
    it 'directs to the correct page when you click the link' do
      visit "/games/#{game.id}"
      click_on 'Set Control Variates'
      page.should have_content 'Edit Control Variables'
      page.should have_content 'Player-Level Control Variables'
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
      [profile1, profile2].each do |profile|
        profile.observations.each do |observation|
          observation.update_attributes(features: { 'feature1' => "#{rand}" })
          observation.players.each do |player|
            if player.symmetry_group.role == 'R1'
              player.update_attributes(features: { 'pfeature1' => "#{rand}" })
            else
              player.update_attributes(features: { 'pfeature2' => "#{rand}" })
            end
          end
        end
      end
    end

    it 'performs the correct payoff adjustments' do
      visit "/control_variables/#{game.simulator_instance_id}/edit"
    end
  end
end
