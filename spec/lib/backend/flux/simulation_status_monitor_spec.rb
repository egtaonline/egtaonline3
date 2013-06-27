require 'backend/flux/simulation_status_monitor'

describe SimulationStatusMonitor do
  class SimulationStatusMonitor
    class Simulation
    end
  end

  let(:local_data_path){ 'fake/path' }
  let(:status_monitor){ SimulationStatusMonitor.new(local_data_path) }
  let(:status_resolver){ double('status resolver') }

  before do
    SimulationStatusResolver.should_receive(:new).with(local_data_path).and_return(status_resolver)
  end

  describe '#update_simulations' do
    let(:simulation){ double(id: 123456) }
    let(:other_simulation){ double(id: 123457) }
    let(:proxy){ double('proxy') }
    let(:connection){ double(acquire: proxy) }

    before do
      SimulationStatusMonitor::Simulation.should_receive(:active).and_return([simulation, other_simulation])
    end

    context 'when there are multiple simulations list in the status update' do
      before do
        proxy.should_receive(:exec!).with("qstat -a | grep egta-").and_return("123456.nyx.engi     bcassell flux     egta-epp_sim             26276   --   --    --  24:00 Q -- \n" +
                                                                              "123457.nyx.engi     bcassell flux     egta-epp_sim             26278   --   --    --  24:00 C -- ")
      end

      it 'delegates to the status_resolver for both' do
        status_resolver.should_receive(:act_on_status).with("Q", simulation)
        status_resolver.should_receive(:act_on_status).with("C", other_simulation)
        status_monitor.update_simulations(connection)
      end
    end

    context 'when a simulation is missing from the status update' do
      let(:other_simulation){ double(id: 123457) }

      before do
        proxy.should_receive(:exec!).with("qstat -a | grep egta-").and_return("123457.nyx.engi     bcassell flux     egta-epp_sim             26278   --   --    --  24:00 C -- ")
      end

      it 'delegates to the status_resolver for both, with nil as the missing status' do
        status_resolver.should_receive(:act_on_status).with(nil, simulation)
        status_resolver.should_receive(:act_on_status).with("C", other_simulation)
        status_monitor.update_simulations(connection)
      end
    end

    context 'when the proxy fails to get the answer' do
      before do
        proxy.should_receive(:exec!).with("qstat -a | grep egta-").and_return("failure")
      end

      it 'does not delegate to the status_resolver' do
        status_resolver.should_not_receive(:act_on_status)
        status_monitor.update_simulations(connection)
      end
    end
  end
end