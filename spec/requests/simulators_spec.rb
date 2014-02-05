require 'spec_helper'

describe "Simulators" do
  before do
    sign_in
  end

  describe "GET /simulators", type: :feature do
    it "displays simulators" do
      simulator = FactoryGirl.create(:simulator)
      visit simulators_path
      page.should have_content(simulator.name)
      page.should have_content(simulator.version)
    end
  end

  describe "GET /simulators/:id", type: :feature do
    it "displays the relevant simulator" do
      simulator = FactoryGirl.create(:simulator)
      visit simulator_path(simulator.id)
      page.should have_content(simulator.name)
      page.should have_content(simulator.version)
    end
  end

#  Covered in feature test
#  describe "POST /simulators", type: :feature do
#  end

  describe "DELETE /simulators/:simulator_id/roles/:role", type: :feature do
    it "removes the relevant role" do
      simulator = FactoryGirl.create(:simulator)
      simulator.add_strategy("Bidder", "A")
      visit simulator_path(simulator.id)
      click_on "Remove Role"
      page.should have_content("Inspect Simulator")
      page.should have_content(simulator.name)
      page.should_not have_content("Bidder")
    end
  end

  context "an existing simulator", type: :feature do
    let!(:simulator){ FactoryGirl.create(:simulator) }

    context "GET /simulators/:id/edit" do
      it "should show the edit page for the simulator" do
        visit edit_simulator_path(simulator.id)
        page.should have_content("Edit Simulator")
        page.should have_content("Email")
        page.should have_content("Zipped Source")
      end
    end

    describe "DELETE /simulators/:id/", type: :feature do
      it "destroys the relevant simulator" do
        visit simulators_path
        click_on "Destroy"
        Simulator.count.should eql(0)
      end
    end

    describe "POST /simulators/:simulator_id/roles", type: :feature do
      it "should add the required role" do
        visit simulator_path(simulator.id)
        fill_in "role", :with => "All"
        click_button "Add Role"
        page.should have_content("Inspect Simulator")
        page.should have_content("All")
        page.should_not have_content("Some errors were found")
      end
    end

    describe "POST /simulators/:simulator_id/roles/:role/strategies", type: :feature do
      it "should add the required strategy" do
        simulator.add_role("All")
        visit simulator_path(simulator.id)
        fill_in "All_strategy", :with => "B.A"
        click_button "Add Strategy"
        page.should have_content("Inspect Simulator")
        page.should have_content("B.A")
      end
    end

    describe "DELETE /simulators/:simulator_id/roles/:role/strategies/:id", type: :feature do
      it "should remove the required strategy" do
        simulator.add_strategy("All", "B.A")
        visit simulator_path(simulator.id)
        click_on "Remove Strategy"
        page.should have_content("Inspect Simulator")
        page.should have_content("All")
        page.should_not have_content("B.A")
      end
    end
  end
end