Dir[File.dirname(__FILE__)+'/backend/*.rb'].each{ |file| require file }

module Backend
  extend SingleForwardable

  class << self
    attr_accessor :connected, :configuration
  end

  def_delegators :configuration, :connection, :simulation_interface,
    :simulator_interface, :queue_quantity, :queue_max
  def_delegator :simulator_interface, :prepare_simulator
  def_delegators :simulation_interface, :prepare_simulation,
    :schedule_simulation, :clean_simulation, :update_simulations

  def self.connected?
    self.connected
  end

  def self.configure
    self.connected = false
    self.configuration ||= Configuration.new
    yield(configuration)
    configuration.setup
  end

  def self.authenticate(options)
    self.connected = connection.authenticate(options)
  end

  class Configuration
    attr_accessor :queue_periodicity, :queue_quantity, :queue_max,
     :simulators_path, :local_data_path, :remote_data_path, :connection,
     :simulation_interface, :simulator_interface, :connection_class,
     :connection_options, :simulation_interface_class,
     :simulation_interface_options, :simulator_interface_class,
     :simulator_interface_options, :simulation_prep_service

    def initialize
      @connection_options = {}
      @simulator_interface_options = {}
      @simulation_interface_options = {}
    end

    def setup
      @connection = @connection_class.new(connection_options)
      @simulation_interface = @simulation_interface_class.new(
        { connection: @connection, simulators_path: @simulators_path,
          local_data_path: @local_data_path,
          remote_data_path: @remote_data_path}.merge(
          @simulation_interface_options))
      @simulator_interface = @simulator_interface_class.new(
        connection: @connection, simulators_path: @simulators_path)
    end
  end
end