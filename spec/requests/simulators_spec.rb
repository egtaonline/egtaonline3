require 'spec_helper'

describe 'Simulators' do
  before do
    sign_in
  end

  describe 'GET /simulators', type: :feature do
    it 'displays simulators' do
      simulator = create(:simulator)
      visit simulators_path
      expect(page).to have_content(simulator.name)
      expect(page).to have_content(simulator.version)
    end
  end

  describe 'GET /simulators/:id', type: :feature do
    it 'displays the relevant simulator' do
      simulator = create(:simulator)
      visit simulator_path(simulator.id)
      expect(page).to have_content(simulator.name)
      expect(page).to have_content(simulator.version)
    end
  end

  describe 'DELETE /simulators/:simulator_id/roles/:role', type: :feature do
    it 'removes the relevant role' do
      simulator = create(:simulator)
      simulator.add_strategy('Bidder', 'A')
      visit simulator_path(simulator.id)
      click_on 'Remove Role'
      expect(page).to have_content('Inspect Simulator')
      expect(page).to have_content(simulator.name)
      expect(page).to_not have_content('Bidder')
    end
  end

  context 'an existing simulator', type: :feature do
    let!(:simulator) { create(:simulator) }

    context 'GET /simulators/:id/edit' do
      it 'should show the edit page for the simulator' do
        visit edit_simulator_path(simulator.id)
        expect(page).to have_content('Edit Simulator')
        expect(page).to have_content('Email')
        expect(page).to have_content('Zipped Source')
      end
    end

    describe 'DELETE /simulators/:id/', type: :feature do
      it 'destroys the relevant simulator' do
        visit simulators_path
        click_on 'Destroy'
        Simulator.count.should eql(0)
      end
    end

    describe 'POST /simulators/:simulator_id/roles', type: :feature do
      it 'should add the required role' do
        visit simulator_path(simulator.id)
        fill_in 'role', with: 'All'
        click_button 'Add Role'
        expect(page).to have_content('Inspect Simulator')
        expect(page).to have_content('All')
        expect(page).to_not have_content('Some errors were found')
      end
    end

    describe 'POST /simulators/:simulator_id/roles/:role/strategies',
             type: :feature do
      it 'should add the required strategy' do
        simulator.add_role('All')
        visit simulator_path(simulator.id)
        fill_in 'All_strategy', with: 'B.A'
        click_button 'Add Strategy'
        expect(page).to have_content('Inspect Simulator')
        expect(page).to have_content('B.A')
      end
    end

    describe 'DELETE /simulators/:simulator_id/roles/:role/strategies/:id',
             type: :feature do
      it 'should remove the required strategy' do
        simulator.add_strategy('All', 'B.A')
        visit simulator_path(simulator.id)
        click_on 'Remove Strategy'
        expect(page).to have_content('Inspect Simulator')
        expect(page).to have_content('All')
        expect(page).to_not have_content('B.A')
      end
    end
  end
end
