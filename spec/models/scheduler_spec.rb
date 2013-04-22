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
end

describe GameScheduler do
  it_behaves_like "a scheduler class"
end
