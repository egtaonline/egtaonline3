Dir[File.dirname(__FILE__)+'/backend/*.rb'].each{ |file| require file }

module Backend
  class << self
    attr_accessor :connected, :configuration
  end

  def self.connected?
    self.connected
  end

  def self.configure
    self.connected = false
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  def self.reset
    self.configuration ||= Configuration.new
    self.connected = false
  end

  def self.authenticate(options)
    self.connected = implementation.authenticate(options)
  end

  def self.prepare_simulator(simulator)
    implementation.prepare_simulator(simulator)
  end

  def self.prepare_simulation(simulation)
    implementation.prepare_simulation(simulation)
  end

  def self.schedule_simulation(simulation)
    implementation.schedule_simulation(simulation)
  end

  def self.clean_simulation(simulation_number)
    implementation.clean_simulation(simulation_number)
  end

  def self.update_simulations
    implementation.update_simulations
  end

  class Configuration
    attr_accessor :implementation, :queue_periodicity, :queue_quantity, :queue_max

    def initialize
      @implementation = FluxBackend.new
      @queue_periodicity = 5.minutes
      @queue_quantity = 30
      @queue_max = 999
    end
  end

  private

  def self.implementation
    self.configuration.implementation
  end
end