require 'backend/flux/simulator_cleaner'

describe SimulatorCleaner do
  let(:simulators_path){ 'fake/path' }
  let(:cleaner){ SimulatorCleaner.new(simulators_path) }

  describe '#clean' do
    let(:connection){ double('connection') }
    let(:simulator){ double(name: 'sim', fullname: 'sim-1', source: double(path: 'path/to/simulator')) }
    let(:flux_proxy){ double('flux_proxy') }

    context 'when connected to flux' do
      before do
        connection.should_receive(:acquire).and_return(flux_proxy)
      end

      it 'requests the old files be deleted' do
        flux_proxy.should_receive(:exec!).with("rm -rf #{simulators_path}/#{simulator.fullname}*; rm -rf #{simulators_path}/#{simulator.name}.zip").and_return("fake")
        cleaner.clean(connection, simulator).should == "fake"
      end
    end

    context 'when not connected to flux' do
      before do
        connection.should_receive(:acquire).and_return(nil)
      end

      it 'informs the caller that the connection was broken' do
        expect{ cleaner.clean(connection, simulator) }.to raise_error("Connection broken.")
      end
    end
  end
end