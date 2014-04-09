require 'spec_helper'

describe 'Simulations' do
  before do
    sign_in
  end

  let!(:simulation) { create(:simulation) }

  context 'GET /simulations', type: :feature do
    it 'displays simulations' do
      visit simulations_path
      expect(page).to have_content('Simulations')
      expect(page).to have_content(simulation.profile.assignment)
      expect(page).to have_content(simulation.id)
      expect(page).to have_content(simulation.state)
    end
  end

  context 'GET /simulations/:id', type: :feature do
    it 'displays the relevant simulator' do
      visit simulation_path(simulation.id)
      expect(page).to have_content('Inspect Simulation')
      expect(page).to have_content(simulation.profile.assignment)
      expect(page).to have_content(simulation.id)
      expect(page).to have_content(simulation.state)
      expect(page).to have_content(simulation.scheduler.simulator.fullname)
    end
  end
end
