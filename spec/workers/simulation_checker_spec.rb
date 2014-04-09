require 'spec_helper'

describe SimulationChecker do
  describe '#perform' do
    let(:simulations) { [double('Simulation')] }

    before do
      Simulation.should_receive(:active).and_return(simulations)
    end

    it 'asks the backend to check each simulation' do
      Backend.should_receive(:update_simulations).with(simulations)

      subject.perform
    end
  end
end
