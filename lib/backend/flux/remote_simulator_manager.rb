require_relative 'simulator_cleaner'
require_relative 'remote_simulator_uploader'

class RemoteSimulatorManager
  def initialize(options)
    @connection = options[:connection]
    @cleaner = SimulatorCleaner.new(options[:simulators_path])
    @uploader = RemoteSimulatorUploader.new(options[:simulators_path])
  end

  def prepare_simulator(simulator)
    begin
      @cleaner.clean(@connection, simulator)
      @uploader.upload(@connection, simulator)
    rescue => e
      simulator.errors.add(:source, "#{e.message} Try again later.")
    end
  end
end
