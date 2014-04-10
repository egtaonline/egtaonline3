require 'backend/flux/remote_simulator_manager'

describe RemoteSimulatorManager do
  let(:connection) { double('connection') }
  let(:simulator_path) { 'fake/path' }
  let(:simulator_manager) do
    RemoteSimulatorManager.new(connection: connection,
                               simulators_path: simulator_path)
  end

  describe '#prepare_simulator' do
    let(:simulator) do
      double(name: 'sim', fullname: 'sim-1',
             source: double(path: 'path/to/simulator'))
    end
    let(:proxy) { double('proxy') }
    let(:cleaner) { double('cleaner') }
    let(:uploader) { double('uploader') }

    before do
      SimulatorCleaner.should_receive(:new).with(simulator_path)
        .and_return(cleaner)
      RemoteSimulatorUploader.should_receive(:new).with(simulator_path)
        .and_return(uploader)
    end

    context 'when clean up is successful' do
      before do
        cleaner.should_receive(:clean).with(connection, simulator)
          .and_return('')
      end

      context 'and the upload is successful' do
        before do
          uploader.should_receive(:upload).with(connection, simulator)
            .and_return(true)
        end

        it do
          expect(simulator_manager.prepare_simulator(simulator)).to be true
        end
      end

      context 'and the upload is unsuccessful' do
        before do
          uploader.should_receive(:upload).with(connection, simulator)
            .and_raise('Fake exception.')
        end

        it 'adds an error to the simulator' do
          errors = double('errors')
          simulator.should_receive(:errors).and_return(errors)
          errors.should_receive(:add).with(
            :source, 'Fake exception. Try again later.')
          simulator_manager.prepare_simulator(simulator)
        end
      end
    end

    context 'when clean up is unsuccessful' do
      before do
        cleaner.should_receive(:clean).with(connection, simulator)
          .and_raise('Fake exception.')
      end

      it 'adds an error to the simulator' do
        errors = double('errors')
        simulator.should_receive(:errors).and_return(errors)
        errors.should_receive(:add).with(
          :source, 'Fake exception. Try again later.')
        simulator_manager.prepare_simulator(simulator)
      end
    end
  end
end
