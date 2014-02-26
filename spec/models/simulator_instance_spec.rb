require 'spec_helper'

describe SimulatorInstance do
  describe '.find_or_create_for' do
    context 'when a matching SimulatorInstance exists' do
      let(:instance){ FactoryGirl.create(:simulator_instance) }
      let(:simulator){ instance.simulator }
      let(:config){ instance.configuration }

      it 'finds the matching simulator_instance' do
        found_instance = SimulatorInstance.find_or_create_for(simulator.id, config)
        found_instance.id.should == instance.id
      end
    end

    context 'when a matching SimulatorInstance does not exist' do
      let(:simulator){ FactoryGirl.create(:simulator) }
      let(:config){ { "a" => "1", "b" => "2" } }
      it 'creates a matching SimulatorInstance' do
        found_instance = SimulatorInstance.find_or_create_for(simulator.id, config)
        found_instance.simulator_id.should == simulator.id
        found_instance.configuration.should == config
      end
    end
  end
end