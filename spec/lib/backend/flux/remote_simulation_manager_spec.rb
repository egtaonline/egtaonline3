require 'backend/flux/remote_simulation_manager'

describe RemoteSimulationManager do
  let(:connection){ double('connection') }
  let(:simulators_path){ 'fake/simulator/path' }
  let(:local_data_path){ 'fake/local/path' }
  let(:remote_data_path){ 'fake/remote/path' }
  let(:simulation_manager){ RemoteSimulationManager.new(connection: connection, simulators_path: simulators_path,
                      local_data_path: local_data_path, remote_data_path: remote_data_path, flux_active_limit: 90) }
  let(:simulation){ double('simulation') }
  let(:flux_policy){ double('policy') }
  let(:pbs_creator){ double('pbs creator')}
  let(:proxy){ double()}
  let(:simulation_submitter){ double('simulation submitter') }
  let(:status_monitor){ double('status monitor') }

  before do
    FluxPolicy.should_receive(:new).with(90).and_return(flux_policy)
    PbsCreator.should_receive(:new).with(simulators_path, local_data_path, remote_data_path).and_return(pbs_creator)
    SimulationSubmitter.should_receive(:new).with(remote_data_path).and_return(simulation_submitter)
    SimulationStatusMonitor.should_receive(:new).with(local_data_path).and_return(status_monitor)
  end

  describe '#prepare_simulation' do
    it 'sets the simulation queue flag and requests' do
      flux_policy.should_receive(:set_queue).with(simulation).and_return(simulation)
      pbs_creator.should_receive(:prepare).with(simulation)
      simulation_manager.prepare_simulation(simulation)
    end
  end

  describe '#schedule_simulation' do
    it 'delegates to SimulationSubmitter' do
      simulation_submitter.should_receive(:submit).with(connection, simulation)
      simulation_manager.schedule_simulation(simulation)
    end
  end

  describe '#update_simulations' do
    it 'delegates to SimulationStatusMonitor' do
      status_monitor.should_receive(:update_simulations).with(connection)
      simulation_manager.update_simulations
    end
  end

  describe '#clean_simulation' do
    it 'removes the file locally since the storage is NFS' do
      FileUtils.should_receive(:rm_rf).with("#{local_data_path}/4")
      simulation_manager.clean_simulation(4)
    end
  end
end