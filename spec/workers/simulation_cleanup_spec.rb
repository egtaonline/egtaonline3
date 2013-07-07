require 'spec_helper'

describe SimulationCleanup do
  describe '#perform' do
    it 'delegates cleaning of the simulation to the backend' do
      Backend.should_receive(:cleanup_simulation).with(1)
      SimulationCleanup.new.perform(1)
    end
  end
end