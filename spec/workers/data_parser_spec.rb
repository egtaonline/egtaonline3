require 'spec_helper'

describe DataParser do
  describe '#perform' do
    let(:simulation) { double(state: 'processing') }
    let(:observation_processor) { double('ObservationProcessor') }

    before do
      Simulation.should_receive(:find).with(1).and_return(simulation)
      Dir.should_receive(:entries).with('fake/path')
        .and_return(['first_observation.json', 'not_valid.json'])
      ObservationProcessor.should_receive(:new)
        .with(simulation, ['fake/path/first_observation.json'])
        .and_return(observation_processor)
    end

    it 'asks the ObservationProcessor to process the valid files' do
      observation_processor.should_receive(:process_files)

      DataParser.new.perform(1, 'fake/path')
    end
  end
end
