require 'spec_helper'

describe SimulatorInstance do
  describe '.find_or_create_for' do
    context 'when a matching SimulatorInstance exists' do
      let(:instance) { create(:simulator_instance) }
      let(:simulator) { instance.simulator }
      let(:config) { instance.configuration }

      it 'finds the matching simulator_instance' do
        found_instance = SimulatorInstance.find_or_create_for(
          simulator.id, config)
        expect(found_instance.id).to eq(instance.id)
      end
    end

    context 'when a matching SimulatorInstance does not exist' do
      let(:simulator) { create(:simulator) }
      let(:config) { { 'a' => '1', 'b' => '2' } }
      it 'creates a matching SimulatorInstance' do
        found_instance = SimulatorInstance.find_or_create_for(
          simulator.id, config)
        expect(found_instance.simulator_id).to eq(simulator.id)
        expect(found_instance.configuration).to eq(config)
      end
    end
  end
end
