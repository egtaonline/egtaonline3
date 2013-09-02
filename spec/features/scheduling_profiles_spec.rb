require 'spec_helper'

describe 'Users can make schedulers to schedule profiles' do
  before do
    sign_in
  end

  shared_examples 'a scheduler' do
    let(:klass){ described_class.to_s.tableize }

    describe 'creating a scheduler with modified configurationn',
      js: true do
      it 'makes the expected scheduler' do
        simulator = FactoryGirl.create(:simulator)
        other_simulator = FactoryGirl.create(:simulator)
        other_simulator.configuration = {'parm1' => '14', 'parm2' => '6'}
        other_simulator.role_configuration = {'Role1' => ['Strat1', 'Strat2'],
          'Role2' => ['Strat3', 'Strat4']}
        other_simulator.save!
        visit "/#{klass}/new"
        select other_simulator.fullname, from: 'selector_simulator_id'
        fill_in_with_hash(
          'Name' => 'test', 'Size' => 2,
          'Default observation requirement' => 10,
          'Observations per simulation' => 10, 'Process memory' => 1000,
          'Time per observation' => 40, 'Parm2' => 7)
        click_button 'Create Scheduler'
        page.should have_content('Parm2: 7')
      end
    end

    describe 'adding a strategy or profile' do
      it 'adds a scheduling requirement' do
        simulator = FactoryGirl.create(:simulator, :with_strategies)
        simulator_instance = FactoryGirl.create(:simulator_instance,
          simulator_id: simulator.id, configuration: { 'fake' => 'value' } )
        scheduler = FactoryGirl.create(described_class.to_s.underscore.to_sym,
          simulator_instance: simulator_instance)
        role = simulator.role_configuration.keys.last
        strategy = simulator.role_configuration[role].last
        visit "/#{klass}/#{scheduler.id}"
        select role, from: 'role'
        fill_in 'role_count', with: 2
        click_button 'Add Role'
        scheduler.reload
        unless described_class == GenericScheduler
          select strategy, from: "#{role}_strategy"
          click_button 'Add Strategy'
        else
          profile = scheduler.add_profile("#{role}: 2 #{strategy}")
          visit "/#{klass}/#{scheduler.id}"
        end
        page.should have_content("#{role}: 2 #{strategy}")
      end
    end

    describe 'removing a strategy or profile' do
      it 'removes a scheduling requirement' do
        simulator = FactoryGirl.create(:simulator, :with_strategies)
        simulator_instance = FactoryGirl.create(:simulator_instance,
          simulator: simulator,
          configuration: { 'fake' => 'value' } )
        scheduler = FactoryGirl.create(described_class.to_s.underscore.to_sym,
          simulator_instance: simulator_instance)
        role = simulator.role_configuration.keys.last
        strategy = simulator.role_configuration[role].last
        unless described_class == GenericScheduler
          scheduler.add_role(role, 2)
          scheduler.add_strategy(role, strategy)
          visit "/#{klass}/#{scheduler.id}"
          click_on 'Remove Strategy'
        else
          profile = scheduler.add_profile("#{role}: 2 #{strategy}")
          scheduler.remove_profile_by_id(profile.id)
          visit "/#{klass}/#{scheduler.id}"
        end
        page.should_not have_content("#{role}: 2 #{strategy}")
      end
    end

    context 'when the scheduler has profiles' do
      let(:scheduler){ FactoryGirl.create(described_class.to_s.underscore.to_sym, :with_profiles)}
      let(:simulator_instance){ scheduler.simulator_instance }
      describe "updating configuration of a scheduler" do
        it "leads to new profiles being created" do
          assignment = simulator_instance.profiles.last.assignment
          visit "/#{klass}/#{scheduler.id}/edit"
          fill_in 'Parm2', with: 23
          click_button 'Update Scheduler'
          page.should have_content('Parm2: 23')
          unless described_class == GenericScheduler
            page.should have_content(assignment)
            Profile.count.should == simulator_instance.profiles.count*2
          else
            page.should_not have_content(assignment)
            Profile.count.should == simulator_instance.profiles.count
          end
        end
      end

      describe 'updating default observation requirement' do
        it 'leads the counts on scheduling requirements to change' do
          unless scheduler.class == GenericScheduler
            count = scheduler.scheduling_requirements.first.count
            new_count = count + 5
            visit "/#{klass}/#{scheduler.id}/edit"
            fill_in "Default observation requirement", with: new_count
            click_button 'Update Scheduler'
            scheduler.reload.scheduling_requirements.first.count.should == new_count
          end
        end
      end
    end
  end

  SCHEDULER_CLASSES.each do |s_class|
    describe s_class do
      it_behaves_like "a scheduler"
    end
  end
end