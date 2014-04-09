require 'spec_helper'

describe SchedulerPresenter do
  describe '#to_json' do
    context 'when no granularity is specified' do
      it 'defaults to the normal to_json' do
        scheduler = double('scheduler')
        scheduler.should_receive(:to_json)
        SchedulerPresenter.new(scheduler).to_json
      end
    end

    context 'when the with_requirements granularity is given' do
      let(:response) do
        reqs = scheduler.scheduling_requirements.map do |requirement|
          { profile_id: requirement.profile_id, requirement: requirement.count,
            current_count: requirement.observations_count }
        end
        "{\"id\":#{scheduler.id},\"name\":\"#{scheduler.name}\",\"type\":" \
        "\"#{scheduler.class}\",\"active\":#{scheduler.active}," \
        "\"process_memory\":#{scheduler.process_memory}," \
        "\"time_per_observation\":#{scheduler.time_per_observation}," \
        "\"observations_per_simulation\":" \
        "#{scheduler.observations_per_simulation}," \
        "\"default_observation_requirement\":" \
        "#{scheduler.default_observation_requirement}," \
        "\"nodes\":#{scheduler.nodes},\"size\":#{scheduler.size}," \
        "\"simulator_id\":#{scheduler.simulator_instance.simulator_id}," \
        "\"configuration\":" +
        scheduler.simulator_instance.configuration.map do |k, v|
          [k, v.to_s]
        end.to_json +
        ",\"scheduling_requirements\":" +
        reqs.sort { |x, y| x[:profile_id] <=> y[:profile_id] }.to_json + '}'
      end
      context 'and the scheduler is non-generic' do
        let(:scheduler) { create(:game_scheduler) }
        before do
          scheduler.simulator.add_strategy('All', 'A')
          scheduler.simulator.add_strategy('All', 'B')
          scheduler.add_role('All', 2)
          scheduler.add_strategy('All', 'A')
          scheduler.add_strategy('All', 'B')
        end

        it 'returns the scheduling requirements' do
          SchedulerPresenter.new(scheduler).to_json(
            granularity: 'with_requirements').should == response
        end
      end
      context 'and the scheduler is generic' do
        let(:scheduler) { create(:generic_scheduler) }
        before do
          scheduler.simulator.add_strategy('All', 'A')
          scheduler.simulator.add_strategy('All', 'B')
          scheduler.add_role('All', 2)
          scheduler.add_profile('All: 2 A', 10)
          scheduler.add_profile('All: 1 A, 1 B', 15)
          scheduler.add_profile('All: 2 B', 20)
        end

        it 'returns the scheduling requirements' do
          SchedulerPresenter.new(scheduler).to_json(
            granularity: 'with_requirements').should == response
        end
      end
    end
  end
end
