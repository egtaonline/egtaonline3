require_relative 'simulation_status_resolver'

class SimulationStatusMonitor
  def initialize(local_data_path)
    @status_resolver = SimulationStatusResolver.new(local_data_path)
  end

  def update_simulations(connection, simulations)
    proxy = connection.acquire
    if proxy
      output = proxy.exec!("qstat -a | grep egta-")
      status_hash = parse_to_hash(output)
      unless status_hash == nil
        simulations.each do |simulation|
          @status_resolver.act_on_status(status_hash[simulation.job_id.to_s], simulation)
        end
      end
    end
  end

  private

  def parse_to_hash(output)
    unless output =~ /^failure/
      parsed_output = {}
      if output != "" && output != nil
        output.split("\n").each{|line| parsed_output[line.split(".").first] = line.split(/\s+/)[9]}
      end
      parsed_output
    else
      nil
    end
  end
end