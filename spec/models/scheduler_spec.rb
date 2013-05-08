require 'spec_helper'

shared_examples 'a scheduler class' do
  describe 'create_with_simulator_instance' do
    let!(:simulator){ FactoryGirl.create(:simulator) }

    it 'relates the new scheduler to a new simulator instance when necessary' do
      expect do
        described_class.create_with_simulator_instance(name: 'fake', configuration: { 'fake' => 'variable', 'fake2' => 'other_variable' },
                                                       process_memory: 1000, size: 2, time_per_observation: 40, simulator_id: simulator.id)
      end.to change{SimulatorInstance.count}.from(0).to(1)
      si = SimulatorInstance.last
      si.configuration.should == { 'fake' => 'variable', 'fake2' => 'other_variable' }
      Scheduler.last.simulator_instance_id.should == si.id
    end

    it 'relates the new scheduler to an existing simulator instance when possible' do
      si = SimulatorInstance.create!(simulator_id: simulator.id, configuration: { 'fake' => 'variable', 'fake2' => 'other_variable' })
      expect do
        described_class.create_with_simulator_instance(name: 'fake', configuration: { 'fake' => 'variable', 'fake2' => 'other_variable' },
                                                       process_memory: 1000, size: 2, time_per_observation: 40, simulator_id: simulator.id)
      end.to_not change{SimulatorInstance.count}.from(1).to(2)
      Scheduler.last.simulator_instance_id.should == si.id
    end
  end
  
  let(:scheduler){ FactoryGirl.create(described_class.to_s.underscore.to_sym) }
  
  describe '#add_role' do
    it 'adds the role to role_configuration' do
      scheduler.add_role('All', 2)
      scheduler.roles.first.name.should == 'All'
      scheduler.roles.first.count.should == 2
      scheduler.roles.first.reduced_count.should == 2
      scheduler.roles.first.strategies.should == []
    end
  end
  
  context 'stubbing ProfileAssociator' do    
    context 'asserting that profile_associator is triggered' do
      before do
        ProfileAssociator.should_receive(:perform_async)
      end
      
      describe '#remove_role' do
        it 'triggers profile association' do
          scheduler.roles.create!(name: "All", count: 2, reduced_count: 2)
          scheduler.remove_role("All")
        end
      end
      
      describe '#add_strategy' do
        it 'triggers profile association' do
          scheduler.roles.create!(name: "All", 'count' => 2, 'reduced_count' => 2)
          scheduler.add_strategy('All', 'A')
        end
      end
      
      describe '#remove_strategy' do
        it 'triggers profile association' do
          scheduler.roles.create!(name: "All", 'count' => 2, 'reduced_count' => 2, 'strategies' => ['A'])
          scheduler.remove_strategy('All', 'A')
        end
      end
    end
    
    context 'stubbed out' do
      before do
        ProfileAssociator.stub(:perform_async)
      end
      
      describe '#remove_role' do
        it "removes the role if present" do
          scheduler.roles.create!(name: "All", 'count' => 2, 'reduced_count' => 2)
          scheduler.remove_role("B")
          scheduler.roles.count.should == 1
          scheduler.remove_role("All")
          scheduler.roles.count.should == 0
        end
      end
      
      describe '#add_strategy' do
        it 'adds the strategy to specified role' do
          scheduler.add_role('A', 1)
          scheduler.add_role('B', 1)
          scheduler.add_strategy('A', 'A1')
          scheduler.add_strategy('A', 'A2')
          scheduler.roles.where(name: 'A').first.strategies.should == ['A1', 'A2']
          scheduler.roles.where(name: 'B').first.strategies.should == []
        end
      end
      
      describe '#remove_strategy' do
        it 'removes the specified strategy from the specified role if possible' do
          scheduler.roles.create!(name: 'Role1', "count" => 1, "reduced_count" => 1, "strategies" => ['A', 'B'])
          scheduler.roles.create!(name: 'Role2', "count" => 1, "reduced_count" => 1, "strategies" => ['A'])
          scheduler.remove_strategy('Role1', 'A')
          scheduler.remove_strategy('Role2', 'B')
          scheduler.roles.where(name: 'Role1').first.strategies.should == ['B']
          scheduler.roles.where(name: 'Role2').first.strategies.should == ['A']
        end
      end
      
      describe '#invalid_role_partition?' do
        it 'returns true if the insufficient players have been assigned' do
          scheduler.add_role('A', 1)
          scheduler.invalid_role_partition?.should == true
        end

        it 'returns true if there are no strategies on one of the roles' do
          scheduler.add_role('A', 1)
          scheduler.add_role('B', 1)
          scheduler.add_strategy('A', 'S1')
          scheduler.invalid_role_partition?.should == true
        end

        it 'returns false when all the players are assigned and each role has a strategy' do
          scheduler.add_role('A', 1)
          scheduler.add_role('B', 1)
          scheduler.add_strategy('A', 'S1')
          scheduler.add_strategy('B', 'S2')
          scheduler.invalid_role_partition?.should == false
        end
      end
    end
  end
  
  describe '#unassigned_player_count' do
    it 'returns the difference between scheduler size and the sum of role counts' do
      scheduler.size = 4
      scheduler.unassigned_player_count.should == 4
      scheduler.add_role('A', 2)
      scheduler.add_role('B', 1)
      scheduler.unassigned_player_count.should == 1
    end
  end
  
  describe '#available_roles' do
    it "shows the roles defined on simulator that aren't defined on the scheduler" do
      simulator = scheduler.simulator_instance.simulator
      simulator.role_configuration = { 'A' => [], 'B' => [] }
      simulator.save!
      scheduler.add_role('A', 2)
      scheduler.available_roles.should == ['B']
    end
  end
  
  describe '#available_strategies' do
    it "shows the strategies defined on the simulator for the role that aren't defined on the scheduler" do
      simulator = scheduler.simulator_instance.simulator
      simulator.role_configuration = { 'A' => [], 'B' => ['B1', 'B2'] }
      simulator.save!
      scheduler.roles.create!(name: 'B', 'count' => 2, 'reduced_count' => 2, 'strategies' => ['B2'])
      scheduler.available_strategies('B').should == ['B1']
    end
  end
  
  describe '#schedule_profile' do
    let(:profile){ FactoryGirl.create(:profile, simulator_instance: scheduler.simulator_instance, observation_count: 3) }
    
    context 'when more observations are required' do
      context 'and the requirement is greater than the observation_per_simulation' do
        it 'creates a simulation with size equal to observation_per_simulation' do
          scheduler.schedule_profile(profile, 10)
          Simulation.last.profile.should == profile
          Simulation.last.size.should == scheduler.observations_per_simulation
        end
      end
      
      context 'and the requirement is less than the observation_per_simulation' do
        it 'creates a simulation with size equal to requirement minus the profile observation count' do
          scheduler.schedule_profile(profile, 5)
          Simulation.last.profile.should == profile
          Simulation.last.size.should == 5-profile.observation_count
        end
      end
    end
    
    context 'when no observations are required' do
      it 'does not create a simulation' do
        scheduler.schedule_profile(profile, 2)
        Simulation.count.should == 0
      end
    end
  end
end

describe GameScheduler do
  it_behaves_like "a scheduler class"
end

describe DeviationScheduler do
  it_behaves_like "a scheduler class"
end

describe DprDeviationScheduler do
  it_behaves_like "a scheduler class"
end

describe DprScheduler do
  it_behaves_like "a scheduler class"
end

describe GenericScheduler do
  it_behaves_like "a scheduler class"
end

describe HierarchicalScheduler do
  it_behaves_like "a scheduler class"
end

describe HierarchicalDeviationScheduler do
  it_behaves_like "a scheduler class"
end