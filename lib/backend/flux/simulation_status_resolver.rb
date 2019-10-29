class SimulationStatusResolver
  ERROR_LIMIT = 255

  def initialize(local_data_path)
    @data_path = local_data_path
  end

  def act_on_status(status, simulation)
    case status
    when 'R'
      simulation.start
    when 'CD', '', nil
      if File.exist?("#{@data_path}/#{simulation.id}/error")
        error_message = File.open("#{@data_path}/#{simulation.id}/error")
          .read(ERROR_LIMIT)
        if error_message
          simulation.fail(error_message)
        else
          simulation.process("#{@data_path}/#{simulation.id}")
        end
      elsif simulation.state == 'queued'
        simulation.start
      else
        simulation.fail('Failed to queue')
      end
    end
  end
end
