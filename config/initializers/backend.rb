require "#{Rails.root}/lib/backend"

Backend.configure do |config|
  config.queue_periodicity = 5.minutes
  config.queue_quantity = 30
  config.implementation.flux_active_limit = 90
  config.implementation.simulations_path = "/mnt/nfs/home/egtaonline/simulations"
  config.implementation.flux_simulations_path = "/nfs/wellman_ls/egtaonline/simulations"
  config.implementation.simulators_path = "/home/wellmangroup/many-agent-simulations"
  config.queue_max = 999
  if (Rails.env.production? && !(File.basename( $0 ) == "rake" && (ARGV[0] =~ /db:/ || ARGV.last == "assets:precompile")))
    config.implementation.setup_connections
  end
end