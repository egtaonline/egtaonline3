require 'spec_helper'

describe SimulationQueuer do
  describe '#perform' do
    let(:simulations){ [ double('simulation1'), double('simulation2') ] }

    before do
      Simulation.should_receive(:queueable).and_return(simulations)
    end

    it 'requests the Backend to prepare and schedule each simulation' do
      simulations.each do |simulation|
        Backend.should_receive(:prepare_simulation).with(simulation)
        Backend.should_receive(:schedule_simulation).with(simulation)
      end
      SimulationQueuer.new.perform
    end
  end
end