require 'spec_helper'

feature 'Users can make schedulers to schedule profiles' do
  background do
    sign_in
  end

  ['game_scheduler'].each do |scheduler|
    scenario "User creates a #{scheduler} for a particular simulator, modifying the config", :js => true do
      simulator1 = FactoryGirl.create(:simulator)
      simulator2 = FactoryGirl.create(:simulator)
      simulator2.configuration = {'parm1' => '14', 'parm2' => '6'}
      simulator2.role_configuration = {'Role1' => ['Strat1', 'Strat2'], 'Role2' => ['Strat3', 'Strat4']}
      simulator2.save!
      visit "/#{scheduler}s/new"
      select simulator2.fullname, from: 'selector_simulator_id'
      fill_in_with_hash('Name' => 'test', 'Size' => 2, 'Default observation requirement' => 10,
                        'Observations per simulation' => 10, 'Process memory' => 1000, 'Time per observation' => 40)
      fill_in 'Parm2', with: 7
      click_button 'Create Scheduler'
      page.should have_content('Parm2: 7')
    end
  end
end