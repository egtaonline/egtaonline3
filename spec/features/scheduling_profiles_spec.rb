require 'spec_helper'

feature 'Users can make schedulers to schedule profiles' do
  background do
    sign_in
  end

  SCHEDULER_CLASSES.collect{ |klass| klass.to_s.underscore }.each do |scheduler|
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

  NONGENERIC_SCHEDULER_CLASSES.collect{ |klass| klass.to_s.underscore }.each do |scheduler|
    scenario "User adds a strategy to a #{scheduler} and a profile is added", :js => true do
      simulator = FactoryGirl.create(:simulator, :with_strategies)
      simulator_instance = FactoryGirl.create(:simulator_instance, simulator_id: simulator.id,
                                              configuration: { 'fake' => 'value' } )
      scheduler1 = FactoryGirl.create(scheduler.to_sym, simulator_instance_id: simulator_instance.id)
      visit "/#{scheduler}s/#{scheduler1.id}"
      role = simulator.role_configuration.keys.last
      strategy = simulator.role_configuration[role].last
      select role, from: 'role'
      fill_in 'role_count', with: 2
      click_button 'Add Role'
      page.should have_content(role)
      ProfileScheduler.should_receive(:perform_in)
      select strategy, from: "#{role}_strategy"
      click_button 'Add Strategy'
      page.should have_content(strategy)
      page.should have_content("#{role}: 2 #{strategy}")
      scheduler1.scheduling_requirements.count.should == 1
    end
  end

  NONGENERIC_SCHEDULER_CLASSES.collect{ |klass| klass.to_s.underscore }.each do |scheduler_klass|
    scenario "User updates the configuration of a #{scheduler_klass} leading to new profiles" do
      scheduler = FactoryGirl.create(scheduler_klass.to_sym, :with_profiles)
      simulator_instance = scheduler.simulator_instance
      visit "/#{scheduler_klass}s/#{scheduler.id}/edit"
      fill_in 'Parm2', with: 7
      ProfileScheduler.should_receive(:perform_in).exactly(3).times
      click_button 'Update Scheduler'
      page.should have_content('Parm2: 7')
      scheduler.reload
      scheduler.simulator_instance.should_not == simulator_instance
      Profile.count.should == simulator_instance.profiles.count*2
    end
  end
end