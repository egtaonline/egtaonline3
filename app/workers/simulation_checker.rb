class SimulationChecker
  include Sidekiq::Worker
  sidekiq_options queue: 'backend'

  def perform
    ActiveRecord::Base.transaction do
      Backend.update_simulations(Simulation.active)
    end
  end
end
