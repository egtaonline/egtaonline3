require 'spec_helper'

describe ObservationProcessor do
  describe 'process_files' do
    let(:simulation){ double(profile: double('Profile'), id: 1) }
    let(:valid_path){ 'some/path.json' }
    let(:invalid_path){ 'some/other/path.json' }
    let(:observation_validator){ double('ObservationValidator') }
    let(:observation_factory){ double('ObservationFactory') }
    subject{ ObservationProcessor.new(simulation, files, observation_validator, observation_factory) }

    context 'when some of the files are valid' do
      let(:files){ [invalid_path, valid_path] }
      let(:data){ double('data') }

      before do
        observation_validator.stub(:validate).with(invalid_path).and_return(nil)
        observation_validator.stub(:validate).with(valid_path).and_return(data)
      end

      it 'calls for observations to be created and finishes the simulation' do
        observation_factory.should_receive(:add_observation).with(data)
        simulation.should_receive(:finish)
      end
    end

    context 'when there are no valid files' do
      let(:files){ [invalid_path, invalid_path] }
      before do
        observation_validator.stub(:validate).with(invalid_path).twice.and_return(nil)
      end

      it 'fails the simulation' do
        simulation.should_receive(:fail).with("No valid observations were found.")
      end
    end

    after do
      subject.process_files
    end
  end
end