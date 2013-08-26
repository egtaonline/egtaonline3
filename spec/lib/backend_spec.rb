require 'backend'

class Numeric
  def minutes
    self*60
  end
end

describe Backend do
  describe 'the SRG configuration works' do
    let(:connection){ double('connection') }
    let(:simulation_interface){ double('simulation_interface') }
    let(:simulator_interface){ double('simulator_interface') }

    before do
      flux_proxy = double('flux_proxy')
      DRbObject.should_receive(:new_with_uri).with('druby://localhost:30000').and_return(flux_proxy)
      Connection.should_receive(:new).with({ proxy: flux_proxy }).and_return(connection)
      RemoteSimulationManager.should_receive(:new).with(connection: connection, simulators_path: "/home/wellmangroup/many-agent-simulations",
                                                        local_data_path: "/mnt/nfs/home/egtaonline/simulations", remote_data_path: '/nfs/wellman_ls/egtaonline/simulations',
                                                        flux_active_limit: 90).and_return(simulation_interface)
      RemoteSimulatorManager.should_receive(:new).with(connection: connection, simulators_path: "/home/wellmangroup/many-agent-simulations").and_return(simulator_interface)
      Backend.configure do |config|
        config.queue_periodicity = 5.minutes
        config.queue_quantity = 30
        config.queue_max = 999
        config.simulators_path = "/home/wellmangroup/many-agent-simulations"
        config.local_data_path = "/mnt/nfs/home/egtaonline/simulations"
        config.remote_data_path = "/nfs/wellman_ls/egtaonline/simulations"
        config.connection_class = Connection
        config.connection_options[:proxy] = DRbObject.new_with_uri('druby://localhost:30000')
        config.simulation_interface_class = RemoteSimulationManager
        config.simulation_interface_options[:flux_active_limit] = 90
        config.simulator_interface_class = RemoteSimulatorManager
      end
    end

    subject{ Backend.configuration }
    its(:connection){ should == connection }
    its(:simulation_interface){ should == simulation_interface }
    its(:simulator_interface){ should == simulator_interface }
    its(:queue_periodicity){ should == 5.minutes }
    its(:queue_quantity){ should eql(30) }
    its(:queue_max){ should eql(999) }
  end

  describe 'API' do

    let(:simulation){ double('Simulation') }

    describe 'authenticate' do
      it 'passes the message along to the backend implementation' do
        Backend.configuration.connection.should_receive(:authenticate).with(uniqname: 'fake', verification_number: 123, password: 'also_fake').and_return(true)
        Backend.authenticate(uniqname: 'fake', verification_number: 123, password: 'also_fake')
      end
    end

    describe 'connected?' do
      it "delegates connected?" do
        Backend.configuration.connection.should_receive(:authenticated?).and_return(true)
        Backend.connected?.should == true
      end
    end

    describe 'schedule_simulation' do
      it 'passes the message along to the backend implementation' do
        Backend.configuration.simulation_interface.should_receive(:schedule_simulation).with(simulation)
        Backend.schedule_simulation(simulation)
      end
    end

    describe 'update_simulations' do
      let(:simulations){ double('Array') }
      it 'passes the message along to the backend implementation' do
        Backend.configuration.simulation_interface.should_receive(
          :update_simulations).with(simulations)
        Backend.update_simulations(simulations)
      end
    end

    describe 'prepare_simulation' do
      it 'passes the message along to the backend implementation' do
        Backend.configuration.simulation_interface.should_receive(:prepare_simulation).with(simulation)
        Backend.prepare_simulation simulation
      end
    end

    describe 'clean_simulation' do
      it 'passes the message along to the backend implementation' do
        Backend.configuration.simulation_interface.should_receive(:clean_simulation).with(simulation)
        Backend.clean_simulation simulation
      end
    end

    describe 'prepare_simulator' do
      let(:simulator){ double('Simulator') }

      it 'passes the message along to the backend implementation' do
        Backend.configuration.simulator_interface.should_receive(:prepare_simulator).with(simulator)
        Backend.prepare_simulator(simulator)
      end
    end
  end

  after :all do
    Backend.configure do |config|
      config.queue_periodicity = 5.minutes
      config.queue_quantity = 30
      config.queue_max = 999
      config.simulators_path = "/home/wellmangroup/many-agent-simulations"
      config.local_data_path = "/mnt/nfs/home/egtaonline/simulations"
      config.remote_data_path = "/nfs/wellman_ls/egtaonline/simulations"
      config.connection_class = Connection
      config.connection_options[:proxy] = DRbObject.new_with_uri('druby://localhost:30000')
      config.simulation_interface_class = RemoteSimulationManager
      config.simulation_interface_options[:flux_active_limit] = 90
      config.simulator_interface_class = RemoteSimulatorManager
    end
  end
end