require 'backend/flux/simulation_status_resolver'

describe SimulationStatusResolver do
  describe '#act_on_status' do
    let(:local_data_path){ "fake/local/path" }
    let(:simulation){ double(id: 3) }
    let(:status_resolver){ SimulationStatusResolver.new(local_data_path) }

    context 'simulation is running' do
      before do
        simulation.should_receive(:start)
      end

      it{ status_resolver.act_on_status("R", simulation) }
    end

    context 'simulation is queued' do
      before do
        simulation.should_not_receive(:start)
        simulation.should_not_receive(:fail)
      end

      it{ status_resolver.act_on_status("Q", simulation) }
    end

    context 'simulation completed successfully' do
      before do
        File.should_receive(:exists?).with(
          "#{local_data_path}/#{simulation.id}/error").and_return(true)
        File.should_receive(:open).with(
          "#{local_data_path}/#{simulation.id}/error").and_return(
          double(read: nil))
        simulation.should_receive(:process).with(
          "#{local_data_path}/#{simulation.id}")
      end

      it{ status_resolver.act_on_status("C", simulation) }
      it{ status_resolver.act_on_status("", simulation) }
      it{ status_resolver.act_on_status(nil, simulation) }
    end

    context 'simulation did not complete successfully' do
      before do
        File.stub(:exists?).with(
          "#{local_data_path}/#{simulation.id}/error").and_return(true)
        File.should_receive(:open).with(
          "#{local_data_path}/#{simulation.id}/error").and_return(
          double(read: 'I has error'))
        simulation.should_receive(:fail).with('I has error')
      end

      it{ status_resolver.act_on_status("C", simulation) }
      it{ status_resolver.act_on_status("", simulation) }
      it{ status_resolver.act_on_status(nil, simulation) }
    end
  end
end