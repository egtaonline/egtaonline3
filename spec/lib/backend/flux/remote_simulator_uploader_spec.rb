require 'backend/flux/remote_simulator_uploader'

describe RemoteSimulatorUploader do
  let(:simulators_path) { 'fake/path' }
  let(:uploader) { RemoteSimulatorUploader.new(simulators_path) }

  describe '#clean' do
    let(:connection) { double('connection') }
    let(:simulator) do
      double(name: 'sim', fullname: 'sim-1',
             source: double(path: 'path/to/simulator'))
    end
    let(:flux_proxy) { double('flux_proxy') }

    context 'when connected to flux' do
      before do
        connection.should_receive(:acquire).and_return(flux_proxy)
      end

      context 'and it successfully uploads the zip file' do
        before do
          flux_proxy.should_receive(:upload!).with(
            'path/to/simulator', "#{simulators_path}/#{simulator.name}.zip")
            .and_return('')
          flux_proxy.should_receive(:exec!).with(
            "[ -f \"#{simulators_path}/#{simulator.name}.zip\" ] && echo " \
            "\"exists\" || echo \"not exists\"").and_return("exists\n")
        end

        it 'unzips it' do
          flux_proxy.should_receive(:exec!).with(
            "cd #{simulators_path} && unzip -uqq #{simulator.name}.zip -d" \
            " #{simulator.fullname} && chmod -R ug+rwx #{simulator.fullname}")
          uploader.upload(connection, simulator)
        end
      end

      context 'and it does not successfully upload the zip file' do
        before do
          flux_proxy.should_receive(:upload!).with(
            'path/to/simulator', "#{simulators_path}/#{simulator.name}.zip")
            .and_return('')
          flux_proxy.should_receive(:exec!).with(
            "[ -f \"#{simulators_path}/#{simulator.name}.zip\" ] && echo " \
            "\"exists\" || echo \"not exists\"").and_return("not exists\n")
        end

        it 'informs the caller of the failure' do
          expect { uploader.upload(connection, simulator) }.to raise_error(
            'Upload failed.')
        end
      end
    end

    context 'when not connected to flux' do
      before do
        connection.should_receive(:acquire).and_return(nil)
      end

      it 'informs the caller that the connection was broken' do
        expect { uploader.upload(connection, simulator) }.to raise_error(
          'Connection broken.')
      end
    end
  end
end
