require 'spec_helper'

describe DataParser do
  describe '#perform' do
    let(:simulation){ double(state: 'processing') }

    before do
      Simulation.should_receive(:find).with(1).and_return(simulation)
      Dir.should_receive(:entries).with("fake/path").and_return(
        ['first_observation.json', 'not_valid.json'])
    end

    it 'passes file paths that appear to be valid to ObservationProcessor' do
      ObservationProcessor.should_receive(:process_files).with(
        simulation, ['fake/path/first_observation.json'])
      DataParser.new.perform(1, 'fake/path')
    end
  end
end