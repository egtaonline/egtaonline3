require 'spec_helper'

describe "GameSchedulers" do
  shared_examples "a game scheduler on requests" do
    before do
      sign_in
    end

    let(:klass){ described_class.to_s }

    context "POST /schedulers/:scheduler_id/roles" do
      it "should add the required role" do
        Simulator.last.add_role("All123")
        visit "/#{klass.tableize}/#{game_scheduler.id}"
        click_on 'Add Role'
        page.should have_content("Inspect #{described_class.to_s.titleize}")
        page.should have_content("All123 #{game_scheduler.size}")
        game_scheduler.reload.roles.count.should eql(1)
      end
    end

    context "DELETE /schedulers/:scheduler_id/roles/:role" do
      it "removes the relevant role" do
        Simulator.last.add_strategy("Bidder", "Strat1")
        game_scheduler.add_role("Bidder", 1)
        visit "/#{klass.tableize}/#{game_scheduler.id}"
        described_class.last.roles.count.should eql(1)
        click_on "Remove Role"
        page.should have_content("Inspect #{klass.titleize}")
        page.should_not have_content("Bidder 1")
        game_scheduler.reload.roles.count.should eql(0)
      end
    end

    describe "POST /schedulers/:scheduler_id/roles/:role/strategies" do
      it "adds the relevant strategy" do
        Simulator.last.add_strategy("Bidder", "Strat1")
        game_scheduler.add_role("Bidder", game_scheduler.size)
        visit "/#{klass.tableize}/#{game_scheduler.id}"
        click_button "Add Strategy"
        page.should have_content("Inspect #{klass.titleize}")
        page.should have_content("Strat1")
        game_scheduler.reload.roles.last.strategies.count.should eql(1)
        game_scheduler.reload.roles.last.strategies.last.should eql("Strat1")
      end
    end

    describe "DELETE /schedulers/:scheduler_id/roles/:role/strategies" do
      it "removes the relevant strategy" do
        Simulator.last.add_strategy("Bidder", "Strat1")
        game_scheduler.add_role("Bidder", 1)
        game_scheduler.add_strategy("Bidder", "Strat1")
        visit "/#{klass.tableize}/#{game_scheduler.id}"
        click_on "Remove Strategy"
        page.should have_content("Inspect #{klass.titleize}")
        page.should_not have_content("Some errors were found")
        game_scheduler.reload.roles.last.strategies.count.should eql(0)
      end
    end
  end

  describe GameScheduler, type: :feature do
    it_behaves_like "a game scheduler on requests" do
      let!(:game_scheduler){FactoryGirl.create(:game_scheduler)}
    end
  end

  describe HierarchicalScheduler, type: :feature do
    it_behaves_like "a game scheduler on requests" do
      let!(:game_scheduler){FactoryGirl.create(:hierarchical_scheduler)}
    end
  end

  describe DeviationScheduler, type: :feature do
    it_behaves_like "a game scheduler on requests" do
      let!(:game_scheduler){FactoryGirl.create(:deviation_scheduler)}
    end
  end

  describe HierarchicalDeviationScheduler, type: :feature do
    it_behaves_like "a game scheduler on requests" do
      let!(:game_scheduler) do
        FactoryGirl.create(:hierarchical_deviation_scheduler)
      end
    end
  end

  describe DprScheduler, type: :feature do
    it_behaves_like "a game scheduler on requests" do
      let!(:game_scheduler) { FactoryGirl.create(:dpr_scheduler) }
    end
  end

  describe DprDeviationScheduler, type: :feature do
    it_behaves_like "a game scheduler on requests" do
      let!(:game_scheduler) { FactoryGirl.create(:dpr_deviation_scheduler) }
    end
  end
end