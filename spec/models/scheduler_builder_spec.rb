require 'spec_helper'

describe SchedulerBuilder do
  SCHEDULER_CLASSES.each do |scheduler_klass|
    describe 'create' do
      let(:simulator) { create(:simulator, :with_strategies) }
      let(:configuration) do
        { 'fake' => 'variable', 'fake2' => 'other_variable' }
      end
      let(:scheduler_details) do
        { name: 'fake', process_memory: 1000, size: 2,
          time_per_observation: 40 }
      end

      context "when making a #{scheduler_klass} & SimulatorInstance exists" do
        before do
          @simulator_instance = SimulatorInstance.create(
            simulator_id: simulator.id, configuration: configuration)
          @scheduler = SchedulerBuilder
            .create(scheduler_klass, scheduler_details,
                    simulator.id, configuration)
        end

        [:name, :process_memory, :size, :time_per_observation].each do |field|
          it { expect(@scheduler.send(field)).to eq(scheduler_details[field]) }
        end

        it { expect(@scheduler.class).to eq(scheduler_klass) }
        it do
          expect(@scheduler.simulator_instance_id)
            .to eq(@simulator_instance.id)
        end
      end

      context "when making #{scheduler_klass} & SimulatorInstance not exist" do
        before do
          @scheduler = SchedulerBuilder.create(
            scheduler_klass, scheduler_details, simulator.id, configuration)
          @simulator_instance = SimulatorInstance.last
        end

        [:name, :process_memory, :size, :time_per_observation].each do |field|
          it { expect(@scheduler.send(field)).to eq(scheduler_details[field]) }
        end

        it { expect(@scheduler.class).to eq(scheduler_klass) }
        it do
          expect(@scheduler.simulator_instance_id)
            .to eq(@simulator_instance.id)
        end
        it { expect(@simulator_instance.simulator_id).to eq(simulator.id) }
        it { expect(@simulator_instance.configuration).to eq(configuration) }
      end
    end
  end

  NONGENERIC_SCHEDULER_CLASSES.map { |klass| klass.to_s.underscore }
    .each do |scheduler_klass|
    describe 'update' do
      let(:scheduler) { create(scheduler_klass, :with_profiles) }
      let(:simulator_instance) { scheduler.simulator_instance }

      context "when updating a #{scheduler_klass} and config is not changed" do
        let(:new_details) do
          { name: scheduler.name,
            process_memory: scheduler.process_memory + 1000,
            size: scheduler.size,
            time_per_observation: scheduler.time_per_observation }
        end

        before do
          @scheduler = SchedulerBuilder.update(
            scheduler, new_details, simulator_instance.configuration)
        end

        it do
          expect(@scheduler.process_memory).to eq(new_details[:process_memory])
        end
        it { expect(@scheduler.simulator_instance).to eq(simulator_instance) }
      end

      context "when updating a #{scheduler_klass} when config is changed" do
        let(:new_details) do
          { name: scheduler.name, process_memory: scheduler.process_memory,
            size: scheduler.size,
            time_per_observation: scheduler.time_per_observation }
        end

        before do
          @scheduler = SchedulerBuilder.update(
            scheduler, new_details, 'new' => 'configuration')
        end

        it do
          expect(@scheduler.simulator_instance).not_to eq(simulator_instance)
        end
        it do
          expect(@scheduler.simulator_instance.configuration)
            .to eq('new' => 'configuration')
        end
        it do
          expect(
            simulator_instance.profiles.first.scheduling_requirements.count)
              .to eq(0)
        end
        it do
          expect(SchedulingRequirement.count)
            .to eq(@scheduler.scheduling_requirements.count)
        end
        it do
          expect(@scheduler.simulator_instance.profiles.count)
            .to eq(simulator_instance.profiles.count)
        end
      end
    end
  end
end
