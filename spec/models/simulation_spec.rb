require 'spec_helper'

describe Simulation do
  context 'filters' do
    before do
      %w(pending queued running failed running complete
         processing).each do |state|
        create(:simulation, state: state)
      end
    end

    describe '.scheduled' do
      context 'when a mixture of simulation states exist' do
        it 'returns simulations with state in [:pending, :queued, :running]' do
          expect(Simulation.scheduled.pluck(:state).sort)
            .to eq(%w(pending queued running running).sort)
        end
      end
    end

    describe '.active' do
      it do
        expect(Simulation.active.pluck(:state).sort)
          .to eq(%w(queued running running).sort)
      end
    end

    describe '.stale' do
      it 'returns old enough simulations' do
        Timecop.freeze(Time.now + 2) do
          expect(Simulation.stale(1).pluck(:state).sort)
            .to eq(%w(queued complete failed).sort)
        end
      end
    end

    describe '.recently_finished' do
      it do
        expect(Simulation.recently_finished.pluck(:state).sort)
          .to eq(%w(failed complete).sort)
      end
    end

    describe '.queueable' do
      it 'returns no more than simulation limit, in pending, sorting by age' do
        Simulation.should_receive(:simulation_limit).and_return(1)
        simulation = create(:simulation, state: 'pending')
        criteria = Simulation.queueable
        expect(criteria.count).to eq(1)
        # it should equal the simulation made in the before do
        criteria.first.should_not == simulation
      end
    end
  end

  context 'flux' do
    let!(:in_neither) { create(:simulation, state: 'pending') }
    let!(:active_on_flux) do
      create(:simulation, state: 'running', qos: 'flux')
    end
    let!(:active_on_other) { create(:simulation, state: 'running') }

    it { expect(Simulation.active_on_flux.to_a).to eq([active_on_flux]) }
    it { expect(Simulation.active_on_other.to_a).to eq([active_on_other]) }
  end

  describe '#start' do
    it 'moves the simulation to running if it is queued' do
      simulation = create(:simulation, state: 'queued')
      simulation.start
      expect(simulation.state).to eq('running')
    end

    it 'does nothing otherwise' do
      simulation = create(:simulation, state: 'complete')
      simulation.start
      expect(simulation.state).to eq('complete')
    end
  end

  describe '#process' do
    it 'updates the state to processing and requests data parsing if active' do
      simulation = create(:simulation, state: 'running')
      DataParser.should_receive(:perform_async).with(simulation.id, 'fake')
      simulation.process('fake')
      expect(simulation.state).to eq('processing')
    end

    it 'does nothing otherwise' do
      simulation = create(:simulation, state: 'complete')
      DataParser.should_not_receive(:perform_async).with(simulation.id, 'fake')
      simulation.process('fake')
      expect(simulation.state).to eq('complete')
    end
  end

  describe '#finish' do
    it 'moves to complete and tries to reschedule' do
      simulation = create(:simulation, state: 'processing')
      ProfileScheduler.should_receive(:perform_in)
        .with(5.minutes, simulation.profile_id)
      simulation.finish
      expect(simulation.state).to eq('complete')
    end

    it 'does nothign if the simulation failed' do
      simulation = create(:simulation, state: 'failed')
      ProfileScheduler.should_not_receive(:perform_in)
        .with(5.minutes, simulation.profile_id)
      simulation.finish
      expect(simulation.state).to eq('failed')
    end
  end

  describe '#queue_as' do
    it 'sets the job id and moves to queued if pending' do
      simulation = create(:simulation, state: 'pending')
      simulation.queue_as(23)
      expect(simulation.job_id).to eq(23)
      expect(simulation.state).to eq('queued')
    end

    it 'does nothing otherwise' do
      simulation = create(:simulation, state: 'running',
                                       job_id: 11)
      simulation.queue_as(23)
      expect(simulation.job_id).to eq(11)
      expect(simulation.state).to eq('running')
    end
  end

  describe '#fail' do
    it 'moves to failed and sets an error_message' do
      simulation = create(:simulation)
      simulation.fail('FAILZORS')
      expect(simulation.error_message).to eq('FAILZORS')
      expect(simulation.state).to eq('failed')
    end
  end

  describe '#requeue' do
    it 'asks for the profile to try scheduling again' do
      simulation = create(:simulation)
      ProfileScheduler.should_receive(:perform_in)
        .with(5.minutes, simulation.profile_id)
      simulation.requeue
    end
  end

  describe '.simulation_limit' do
    it 'returns 0 when no more simulations can be scheduled' do
      Backend.should_receive(:queue_quantity).and_return(10)
      Backend.should_receive(:queue_max).and_return(15)
      Simulation.should_receive(:active).and_return(double(count: 16))
      expect(Simulation.simulation_limit).to eq(0)
    end

    it 'returns the queue quantity when there is excess space' do
      Backend.should_receive(:queue_quantity).and_return(10)
      Backend.should_receive(:queue_max).and_return(25)
      Simulation.should_receive(:active).and_return([])
      expect(Simulation.simulation_limit).to eq(10)
    end

    it 'otherwise returns the difference between queue max and active count' do
      Backend.should_receive(:queue_quantity).and_return(10)
      Backend.should_receive(:queue_max).and_return(25)
      Simulation.should_receive(:active).and_return(double(count: 17))
      expect(Simulation.simulation_limit).to eq(8)
    end
  end
end
