require 'data_processing'

describe ObservationProcessor do
  describe 'process_files' do
    let(:simulation) { double(profile: double('Profile'), id: 1) }
    let(:valid_path) { 'some/path.json' }
    let(:invalid_path) { 'some/other/path.json' }
    let(:observation_validator) { double('ObservationValidator') }
    let(:observation_builder) { double('ObservationBuilder') }
    let(:cv_builder) { double('ControlVariableBuilder') }
    subject do
      ObservationProcessor.new(simulation, files, observation_validator,
                               observation_builder, cv_builder)
    end

    context 'when some of the files are valid' do
      let(:files) { [invalid_path, valid_path] }
      let(:data) { double('data') }

      before do
        observation_validator.stub(:validate).with(invalid_path)
          .and_return(nil)
        observation_validator.stub(:validate).with(valid_path).and_return(data)
      end

      it 'calls for observations to be created & finishes the simulation' do
        cv_builder.should_receive(:extract_control_variables).with(data)
        observation = double('observation')
        observation_builder.should_receive(:add_observation).with(data)
          .and_return(observation)
        AggregateUpdater.should_receive(:update).with(
          [observation], simulation.profile)
        simulation.should_receive(:finish)
      end
    end

    context 'when there are no valid files' do
      let(:files) { [invalid_path, invalid_path] }
      before do
        observation_validator.stub(:validate).with(invalid_path)
          .twice.and_return(nil)
      end

      it 'fails the simulation' do
        simulation.should_receive(:fail).with(
          'No valid observations were found.')
      end
    end

    after do
      subject.process_files
    end
  end
end
