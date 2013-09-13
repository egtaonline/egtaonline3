require 'spec_helper'

describe Simulation do
  context 'filters' do
    before do
      ['pending','queued','running','failed','running','complete',
       'processing'].each do |state|
        FactoryGirl.create(:simulation, state: state)
      end
    end

    describe '.scheduled' do
      context 'when a mixture of simulation states exist' do
        it 'returns simulations with state in [:pending, :queued, :running]' do
          Simulation.scheduled.pluck(:state).sort.should ==
            ['pending', 'queued', 'running', 'running'].sort
        end
      end
    end

    describe '.active' do
      it { Simulation.active.pluck(:state).sort.should ==
        ['queued', 'running', 'running'].sort }
    end

    # use TimeCop or something to test this at some point
    describe '.stale' do
      it 'returns old enough simulations' do
        Timecop.freeze(Time.now+2) do
          Simulation.stale(1).pluck(:state).sort.should ==
            ['queued', 'complete', 'failed'].sort
        end
      end
    end

    describe '.recently_finished' do
      it { Simulation.recently_finished.pluck(:state).sort.should ==
        ['failed','complete'].sort }
    end

    describe '.queueable' do
      it 'returns no more than simulation limit, in pending, sorting by age' do
        Simulation.should_receive(:simulation_limit).and_return(1)
        simulation = FactoryGirl.create(:simulation, state: 'pending')
        criteria = Simulation.queueable
        criteria.count.should == 1
        # it should equal the simulation made in the before do
        criteria.first.should_not == simulation
      end
    end
  end

  context 'flux' do
    let!(:in_neither){ FactoryGirl.create(:simulation, state: 'pending') }
    let!(:active_on_flux) do
      FactoryGirl.create(:simulation, state: 'running', qos: 'flux')
    end
    let!(:active_on_other){ FactoryGirl.create(:simulation, state: 'running') }

    it { Simulation.active_on_flux.to_a == [active_on_flux] }
    it { Simulation.active_on_other.to_a == [active_on_other] }
  end

  describe '#start' do
    it 'moves the simulation to running if it is queued' do
      simulation = FactoryGirl.create(:simulation, state: 'queued')
      simulation.start
      simulation.state.should == 'running'
    end

    it 'does nothing otherwise' do
      simulation = FactoryGirl.create(:simulation, state: 'complete')
      simulation.start
      simulation.state.should == 'complete'
    end
  end

  describe '#process' do
    it 'updates the state to processing and requests data parsing if active' do
      simulation = FactoryGirl.create(:simulation, state: 'running' )
      DataParser.should_receive(:perform_async).with(simulation.id, 'fake')
      simulation.process('fake')
      simulation.state.should == 'processing'
    end

    it 'does nothing otherwise' do
      simulation = FactoryGirl.create(:simulation, state: 'complete')
      DataParser.should_not_receive(:perform_async).with(simulation.id, 'fake')
      simulation.process('fake')
      simulation.state.should == 'complete'
    end
  end

  describe '#finish' do
    it 'moves to complete and tries to reschedule' do
      simulation = FactoryGirl.create(:simulation, state: 'processing' )
      ProfileScheduler.should_receive(:perform_in).with(5.minutes,
        simulation.profile_id)
      simulation.finish
      simulation.state.should == 'complete'
    end

    it 'does nothign if the simulation failed' do
      simulation = FactoryGirl.create(:simulation, state: 'failed' )
      ProfileScheduler.should_not_receive(:perform_in).with(5.minutes,
        simulation.profile_id)
      simulation.finish
      simulation.state.should == 'failed'
    end
  end

  describe '#queue_as' do
    it 'sets the job id and moves to queued if pending' do
      simulation = FactoryGirl.create(:simulation, state: 'pending' )
      simulation.queue_as(23)
      simulation.job_id.should == 23
      simulation.state.should == 'queued'
    end

    it 'does nothing otherwise' do
      simulation = FactoryGirl.create(:simulation, state: 'running',
        job_id: 11 )
      simulation.queue_as(23)
      simulation.job_id.should == 11
      simulation.state.should == 'running'
    end
  end

  describe '#fail' do
    it 'moves to failed and sets an error_message' do
      simulation = FactoryGirl.create(:simulation)
      simulation.fail('FAILZORS')
      simulation.error_message.should == 'FAILZORS'
      simulation.state.should == 'failed'
    end
  end

  describe '#requeue' do
    it 'asks for the profile to try scheduling again' do
      simulation = FactoryGirl.create(:simulation)
      ProfileScheduler.should_receive(:perform_in).with(5.minutes,
        simulation.profile_id)
      simulation.requeue
    end
  end

  describe '.simulation_limit' do
    it 'returns 0 when no more simulations can be scheduled' do
      Backend.should_receive(:queue_quantity).and_return(10)
      Backend.should_receive(:queue_max).and_return(15)
      Simulation.should_receive(:active).and_return(double(count: 16))
      Simulation.simulation_limit.should == 0
    end

    it 'returns the queue quantity when there is excess space' do
      Backend.should_receive(:queue_quantity).and_return(10)
      Backend.should_receive(:queue_max).and_return(25)
      Simulation.should_receive(:active).and_return([])
      Simulation.simulation_limit.should == 10
    end

    it 'otherwise returns the difference between queue max and active count' do
      Backend.should_receive(:queue_quantity).and_return(10)
      Backend.should_receive(:queue_max).and_return(25)
      Simulation.should_receive(:active).and_return(double(count: 17))
      Simulation.simulation_limit.should == 8
    end
  end
end
