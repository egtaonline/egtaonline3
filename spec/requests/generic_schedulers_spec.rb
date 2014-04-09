require 'spec_helper'

describe 'GenericSchedulers' do
  before do
    sign_in
  end

  let!(:scheduler) { create(:generic_scheduler) }

  context 'POST /schedulers/:scheduler_id/roles', type: :feature do
    it 'should add the required role' do
      Simulator.last.add_role('All123')
      visit "/generic_schedulers/#{scheduler.id}"
      click_on 'Add Role'
      expect(page).to have_content("All123 #{scheduler.size}")
      scheduler.reload.roles.count.should eql(1)
    end
  end

  context 'DELETE /schedulers/:scheduler_id/roles/:role', type: :feature do
    it 'removes the relevant role' do
      Simulator.last.add_strategy('Bidder', 'Strat1')
      scheduler.add_role('Bidder', 1)
      visit "/generic_schedulers/#{scheduler.id}"
      click_on 'Remove Role'
      expect(page).to_not have_content('Bidder 1')
      scheduler.reload.roles.count.should eql(0)
    end
  end

  describe 'generic schedulers should not let users add strategies directly',
           type: :feature do
    it 'should not show strategies or have an Add Strategy button' do
      scheduler.simulator.add_strategy('Bidder', 'Strat1')
      scheduler.simulator.add_strategy('Bidder', 'MadeUpStrategy')
      scheduler.add_role('Bidder', scheduler.size)
      scheduler.add_profile('Bidder: 2 MadeUpStrategy')
      visit "/generic_schedulers/#{scheduler.id}"
      expect(page).to_not have_content('Add Strategy')
      expect(page).to_not have_content('Strat1')
    end
  end
end
