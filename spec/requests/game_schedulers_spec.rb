require 'spec_helper'

describe 'GameSchedulers' do
  shared_examples 'a game scheduler on requests' do
    before do
      sign_in
    end

    let(:klass) { described_class.to_s }

    context 'POST /schedulers/:scheduler_id/roles' do
      it 'should add the required role' do
        Simulator.last.add_role('All123')
        visit "/#{klass.tableize}/#{game_scheduler.id}"
        click_on 'Add Role'
        expect(page)
          .to have_content("Inspect #{described_class.to_s.titleize}")
        expect(page).to have_content("All123 #{game_scheduler.size}")
        game_scheduler.reload.roles.count.should eql(1)
      end
    end

    context 'DELETE /schedulers/:scheduler_id/roles/:role' do
      it 'removes the relevant role' do
        Simulator.last.add_strategy('Bidder', 'Strat1')
        game_scheduler.add_role('Bidder', 1)
        visit "/#{klass.tableize}/#{game_scheduler.id}"
        described_class.last.roles.count.should eql(1)
        click_on 'Remove Role'
        expect(page).to have_content("Inspect #{klass.titleize}")
        expect(page).to_not have_content('Bidder 1')
        game_scheduler.reload.roles.count.should eql(0)
      end
    end

    describe 'POST /schedulers/:scheduler_id/roles/:id/add_strategy' do
      it 'adds the relevant strategy' do
        Simulator.last.add_strategy('Bidder', 'A.B')
        game_scheduler.add_role('Bidder', game_scheduler.size)
        visit "/#{klass.tableize}/#{game_scheduler.id}"
        click_button 'Add Strategy'
        expect(page).to have_content("Inspect #{klass.titleize}")
        expect(page).to have_content('A.B')
        game_scheduler.reload.roles.last.strategies.count.should eql(1)
        game_scheduler.reload.roles.last.strategies.last.should eql('A.B')
      end
    end

    describe 'POST /schedulers/:scheduler_id/roles/:id/remove_strategy' do
      it 'removes the relevant strategy' do
        Simulator.last.add_strategy('Bidder', 'A.B')
        game_scheduler.add_role('Bidder', 1)
        game_scheduler.add_strategy('Bidder', 'A.B')
        visit "/#{klass.tableize}/#{game_scheduler.id}"
        click_on 'Remove Strategy'
        expect(page).to have_content("Inspect #{klass.titleize}")
        expect(page).to_not have_content('Some errors were found')
        game_scheduler.reload.roles.last.strategies.count.should eql(0)
      end
    end
  end

  describe GameScheduler, type: :feature do
    it_behaves_like 'a game scheduler on requests' do
      let!(:game_scheduler) { create(:game_scheduler) }
    end
  end

  describe HierarchicalScheduler, type: :feature do
    it_behaves_like 'a game scheduler on requests' do
      let!(:game_scheduler) { create(:hierarchical_scheduler) }
    end
  end

  describe DeviationScheduler, type: :feature do
    it_behaves_like 'a game scheduler on requests' do
      let!(:game_scheduler) { create(:deviation_scheduler) }
    end
  end

  describe HierarchicalDeviationScheduler, type: :feature do
    it_behaves_like 'a game scheduler on requests' do
      let!(:game_scheduler) do
        create(:hierarchical_deviation_scheduler)
      end
    end
  end

  describe DprScheduler, type: :feature do
    it_behaves_like 'a game scheduler on requests' do
      let!(:game_scheduler) { create(:dpr_scheduler) }
    end
  end

  describe DprDeviationScheduler, type: :feature do
    it_behaves_like 'a game scheduler on requests' do
      let!(:game_scheduler) { create(:dpr_deviation_scheduler) }
    end
  end
end
