require "#{Rails.root}/lib/backend"
require 'drb/drb'

Backend.configure do |config|
  config.queue_periodicity = 5.minutes
  config.queue_quantity = 30
  config.queue_max = 999
  config.simulators_path = '/nfs/turbo/coe-wellman-egta/many-agent-simulations'
  config.local_data_path = '/mnt/nfs/home/egtaonline/simulations'
  config.remote_data_path = '/nfs/wellman_ls/egtaonline/simulations'
  config.connection_class = Connection
  config.connection_options[:proxy] = DRbObject.new_with_uri('druby://localhost:30000')
  config.simulation_interface_class = RemoteSimulationManager
  config.simulation_interface_options[:flux_active_limit] = 200
  config.simulator_interface_class = RemoteSimulatorManager
end
