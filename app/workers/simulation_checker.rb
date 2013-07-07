class SimulationChecker
  include Sidekiq::Worker

  def perform
    Backend.update_simulations(Simulation.active)
  end
end