require 'spec_helper'

describe "Simulations" do
  before do
    sign_in
  end

  let!(:simulation){ FactoryGirl.create(:simulation)}

  context "GET /simulations", type: :feature do
    it "displays simulations" do
      visit simulations_path
      page.should have_content("Simulations")
      page.should have_content(simulation.profile.assignment)
      page.should have_content(simulation.id)
      page.should have_content(simulation.state)
    end
  end

  context "GET /simulations/:id", type: :feature do
    it "displays the relevant simulator" do
      visit simulation_path(simulation.id)
      page.should have_content("Inspect Simulation")
      page.should have_content(simulation.profile.assignment)
      page.should have_content(simulation.id)
      page.should have_content(simulation.state)
      page.should have_content(simulation.scheduler.simulator.fullname)
    end
  end
end