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
      scheduler.reload.role_configuration.should == { 'All' => { 'count' => 2, 'strategies' => [] } }
    end
  end
  
  describe '#remove_role' do
    it "removes the role if present" do
      scheduler.role_configuration = { "All" => { 'count' => 2, 'strategies' => ["A1"] } }
      scheduler.save!
      scheduler.reload.remove_role("B")
      scheduler.reload.role_configuration.should == { "All" => { 'count' => 2, 'strategies' => ["A1"] } }
      scheduler.remove_role("All")
      scheduler.reload.role_configuration.should == { }
    end
  end
  
  describe '#add_strategy' do
    it 'adds the strategy to specified role' do
      scheduler.add_role('A', 1)
      scheduler.add_role('B', 1)
      scheduler.add_strategy('A', 'A1')
      scheduler.reload.role_configuration.should == { "A" => { "count" => 1, "strategies" => ["A1"] },
                                                      "B" => { "count" => 1, "strategies" => [] } }
    end
  end
  
  describe '#remove_strategy' do
    it 'removes the specified strategy from the specified role if possible' do
      scheduler.role_configuration = { 'Role1' => { "count" => 1, "strategies" => ['A', 'B'] },
                                       'Role2' => { "count" => 1, "strategies" => ['A'] } }
      scheduler.remove_strategy('Role1', 'A')
      scheduler.reload.role_configuration.should == { 'Role1' => { "count" => 1, "strategies" => ['B'] },
                                                      'Role2' => { "count" => 1, "strategies" => ['A'] } }
      scheduler.remove_strategy('Role2', 'B')
      scheduler.reload.role_configuration.should == { 'Role1' => { "count" => 1, "strategies" => ['B'] },
                                                      'Role2' => { "count" => 1, "strategies" => ['A'] } }
    end
  end
  
  describe '#unassigned_player_count' do
    it 'returns the difference between scheduler size and the sum of role counts' do
      scheduler.size = 4
      scheduler.unassigned_player_count.should == 4
      scheduler.role_configuration = { 'A' => { 'count' => 2, 'strategies' => [] },
                                       'B' => { 'count' => 1, 'strategies' => [] } }
      scheduler.unassigned_player_count.should == 1
    end
  end
  
  describe '#available_roles' do
    it "shows the roles defined on simulator that aren't defined on the scheduler" do
      simulator = scheduler.simulator_instance.simulator
      simulator.role_configuration = { 'A' => [], 'B' => [] }
      simulator.save!
      scheduler.role_configuration = { 'A' => { 'count' => 2, 'strategies' => [] } }
      scheduler.available_roles.should == ['B']
    end
  end
  
  describe '#available_strategies' do
    it "shows the strategies defined on the simulator for the role that aren't defined on the scheduler" do
      simulator = scheduler.simulator_instance.simulator
      simulator.role_configuration = { 'A' => [], 'B' => ['B1', 'B2'] }
      simulator.save!
      scheduler.role_configuration = { 'B' => { 'count' => 2, 'strategies' => ['B2'] } }
      scheduler.available_strategies('B').should == ['B1']
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