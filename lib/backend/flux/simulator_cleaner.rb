class SimulatorCleaner
  def initialize(simulators_path)
    @simulators_path = simulators_path
  end

  def clean(connection, simulator)
    proxy = connection.acquire
    if proxy
      proxy.exec!("rm -rf #{@simulators_path}/#{simulator.fullname}*; " \
                  "rm -rf #{@simulators_path}/#{simulator.name}.zip")
    else
      fail('Connection broken.')
    end
  end
end
