class SimulationCleanup
  include Sidekiq::Worker
  sidekiq_options queue: 'backend'

  def perform(simulation_id)
    Backend.cleanup_simulation(1)
  end
end