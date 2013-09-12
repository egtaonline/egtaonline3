class SimulationStatusResolver
  ERROR_LIMIT = 255

  def initialize(local_data_path)
    @data_path = local_data_path
  end

  def act_on_status(status, simulation)
    case status
    when "R"
      simulation.start
    when "C", "", nil
      error_message = check_for_errors("#{@data_path}/#{simulation.id}")
      if error_message
        simulation.fail(error_message)
      else
        simulation.process("#{@data_path}/#{simulation.id}")
      end
    end
  end

  private

  def check_for_errors(location)
    count = 0
    # wait on NFS
    while !File.exists?(location+"/error")
      count += 1
      break if count == 5
      sleep 5
    end
    File.exists?(location+'/error') ? File.open(location+"/error").read(ERROR_LIMIT) : 'Files were not found in NFS.'
  end
end