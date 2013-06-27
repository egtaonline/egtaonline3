require 'backend/flux/simulation_submitter'

describe SimulationSubmitter do
  let(:remote_data_path){ 'fake/remote/path' }
  let(:submitter){ SimulationSubmitter.new(remote_data_path) }
  let(:proxy){ double('flux proxy') }
  let(:connection){ double(acquire: proxy) }

  describe '#submit' do
    let(:simulation){ double(id: 1) }

    context 'when no exceptions are raised' do
      before do
        proxy.should_receive(:exec!).with("qsub -V -r n #{remote_data_path}/#{simulation.id}/wrapper").and_return(value)
      end

      context 'when the submission is a success' do
        let(:value){ "123534123.flux-login.engin.umich.edu" }

        it 'moves the simulation to the queued state with job id from the submission' do
          simulation.should_receive(:queue_as).with(123534123)
          submitter.submit(connection, simulation)
        end
      end

      context 'when the response is incomprehensible data' do
        let(:value){ "gibberish" }

        it 'fails the simulation' do
          simulation.should_receive(:fail).with("Submission failed: gibberish")
          submitter.submit(connection, simulation)
        end
      end
    end

    context 'when an exception is raised' do
      let(:value){ "123534123.flux-login.engin.umich.edu" }

      before do
        proxy.stub(:exec!).with("qsub -V -r n fake/remote/path/#{simulation.id}/wrapper").and_raise("Failure")
      end

      it 'fails the simulation with the error message' do
        simulation.should_receive(:fail).with("Submission failed: Failure")
        submitter.submit(connection, simulation)
      end
    end
  end
end