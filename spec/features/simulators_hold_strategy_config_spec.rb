require 'spec_helper'

feature 'Users can add roles and strategies to simulator' do
  background do
    sign_in
  end

  let(:simulator) { create(:simulator) }

  scenario 'simulator with no previous roles or strategies' do
    visit simulator_path(simulator)
    fill_in 'role', with: 'Player1'
    click_on 'Add Role'
    expect(page).to have_content('Player1')
    fill_in 'Player1_strategy', with: 'A:Strategy'
    click_on 'Add Strategy'
    expect(page).to have_content('A:Strategy')
    fill_in 'role', with: 'Player2'
    click_on 'Add Role'
    expect(page).to have_content('Player2')
    expect(simulator.reload.role_configuration)
      .to eq('Player1' => ['A:Strategy'], 'Player2' => [])
  end
end
