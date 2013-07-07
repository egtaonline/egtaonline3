class SimulationCleanup
  include Sidekiq::Worker

  def perform(simulation_id)
    Backend.cleanup_simulation(1)
  end
end