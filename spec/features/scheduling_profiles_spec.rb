require 'spec_helper'

feature 'Users can make schedulers to schedule profiles' do
  background do
    sign_in
  end

  scenario 'User creates a scheduler for a particular simulator, modifying the config', js: true do
    simulator = FactoryGirl.create(:simulator)
    other_simulator = FactoryGirl.create(:simulator)
    other_simulator.configuration = {'parm1' => '14', 'parm2' => '6'}
    other_simulator.role_configuration = {'Role1' => ['Strat1', 'Strat2'], 'Role2' => ['Strat3', 'Strat4']}
    other_simulator.save!
    visit "/game_schedulers/new"
    select other_simulator.fullname, from: 'selector_simulator_id'
    fill_in_with_hash('Name' => 'test', 'Size' => 2, 'Default observation requirement' => 10,
                        'Observations per simulation' => 10, 'Process memory' => 1000, 'Time per observation' => 40, 'Parm2' => 7)
    click_button 'Create Scheduler'
    page.should have_content('Parm2: 7')
  end

  scenario 'User adds a strategy to a scheduler and a scheduling requirement is added' do
    simulator = FactoryGirl.create(:simulator, :with_strategies)
    simulator_instance = FactoryGirl.create(:simulator_instance, simulator_id: simulator.id,
                                            configuration: { 'fake' => 'value' } )
    scheduler = FactoryGirl.create(:game_scheduler, simulator_instance_id: simulator_instance.id)
    visit "/game_schedulers/#{scheduler.id}"
    role = simulator.role_configuration.keys.last
    strategy = simulator.role_configuration[role].last
    select role, from: 'role'
    fill_in 'role_count', with: 2
    click_button 'Add Role'
    page.should have_content(role)
    select strategy, from: "#{role}_strategy"
    click_button 'Add Strategy'
    page.should have_content(strategy)
    page.should have_content("#{role}: 2 #{strategy}")
  end

  scenario 'User removes a strategy from a scheduler and a scheduling requirement is removed' do
    simulator = FactoryGirl.create(:simulator, :with_strategies)
    simulator_instance = FactoryGirl.create(:simulator_instance, simulator_id: simulator.id,
                                            configuration: { 'fake' => 'value' } )
    scheduler = FactoryGirl.create(:game_scheduler, simulator_instance_id: simulator_instance.id)
    visit "/game_schedulers/#{scheduler.id}"
    role = simulator.role_configuration.keys.last
    strategy = simulator.role_configuration[role].last
    select role, from: 'role'
    fill_in 'role_count', with: 2
    click_button 'Add Role'
    select strategy, from: "#{role}_strategy"
    click_button 'Add Strategy'
    click_link 'Remove Strategy'
    page.should_not have_content("#{role}: 2 #{strategy}")
  end


  scenario "User updates the configuration of a scheduler leading to new profiles" do
    scheduler = FactoryGirl.create(:game_scheduler, :with_profiles)
    simulator_instance = scheduler.simulator_instance
    assignment = simulator_instance.profiles.last.assignment
    visit "/game_schedulers/#{scheduler.id}/edit"
    fill_in 'Parm2', with: 23
    click_button 'Update Scheduler'
    page.should have_content('Parm2: 23')
    page.should have_content(assignment)
    Profile.count.should == simulator_instance.profiles.count*2
  end
end