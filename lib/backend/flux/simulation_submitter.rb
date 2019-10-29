class SimulationSubmitter
  def initialize(remote_data_path)
    @data_path = remote_data_path
  end

  def submit(connection, simulation)
    proxy = connection.acquire
    if proxy
      begin
        response = proxy.exec!(
          "SBATCH --export=ALL --no-requeue #{@data_path}/#{simulation.id}/wrapper")
        if response =~ /\A(\d+)/
          simulation.queue_as Regexp.last_match[0].to_i
        else
          simulation.fail "Submission failed: #{response}"
        end
      rescue => e
        simulation.fail "Submission failed: #{e}"
      end
    end
  end
end
