require 'spec_helper'

describe SchedulerFactory do
  SCHEDULER_CLASSES.each do |scheduler_klass|
    describe 'create' do
      let(:simulator){ FactoryGirl.create(:simulator, :with_strategies) }
      let(:configuration){ { 'fake' => 'variable', 'fake2' => 'other_variable' } }
      let(:scheduler_details){ { name: 'fake', process_memory: 1000, size: 2, time_per_observation: 40 } }

      context "when constructing a #{scheduler_klass} and a matching SimulatorInstance exists" do
        before do
          @simulator_instance = SimulatorInstance.create(simulator_id: simulator.id, configuration: configuration)
          @scheduler = SchedulerFactory.create(scheduler_klass, scheduler_details, simulator.id, configuration)
        end

        [:name, :process_memory, :size, :time_per_observation].each do |field|
          it { @scheduler.send(field).should == scheduler_details[field] }
        end

        it{ @scheduler.class.should == scheduler_klass }
        it{ @scheduler.simulator_instance_id.should == @simulator_instance.id }
      end

      context "when constructing a #{scheduler_klass} and a matching SimulatorInstance does not exist" do
        before do
          @scheduler = SchedulerFactory.create(scheduler_klass, scheduler_details, simulator.id, configuration)
          @simulator_instance = SimulatorInstance.last
        end

        [:name, :process_memory, :size, :time_per_observation].each do |field|
          it { @scheduler.send(field).should == scheduler_details[field] }
        end

        it{ @scheduler.class.should == scheduler_klass }
        it{ @scheduler.simulator_instance_id.should == @simulator_instance.id }
        it{ @simulator_instance.simulator_id.should == simulator.id }
        it{ @simulator_instance.configuration.should == configuration }
      end
    end
  end

  NONGENERIC_SCHEDULER_CLASSES.collect{ |klass| klass.to_s.underscore }.each do |scheduler_klass|
    describe 'update' do
      let(:scheduler){ FactoryGirl.create(scheduler_klass, :with_profiles) }
      let(:simulator_instance){ scheduler.simulator_instance }

      context "when updating a #{scheduler_klass} and the run time configuration is not changed" do
        let(:new_details){ { name: scheduler.name, process_memory: scheduler.process_memory+1000, size: scheduler.size, time_per_observation: scheduler.time_per_observation } }

        before do
          @scheduler = SchedulerFactory.update(scheduler, new_details, simulator_instance.configuration)
        end

        it { @scheduler.process_memory.should == new_details[:process_memory] }
        it { @scheduler.simulator_instance.should == simulator_instance }
      end

      context "when updating a #{scheduler_klass} when the run time configuration is changed" do
        let(:new_details){ { name: scheduler.name, process_memory: scheduler.process_memory, size: scheduler.size, time_per_observation: scheduler.time_per_observation } }

        before do
           @scheduler = SchedulerFactory.update(scheduler, new_details, { "new" => "configuration" })
        end

        it { @scheduler.simulator_instance.should_not == simulator_instance }
        it { @scheduler.simulator_instance.configuration.should == { "new" => "configuration" } }
        it { simulator_instance.profiles.first.scheduling_requirements.count.should == 0 }
        it { SchedulingRequirement.count.should == @scheduler.scheduling_requirements.count }
        it { @scheduler.simulator_instance.profiles.count.should == simulator_instance.profiles.count }
      end
    end
  end
end