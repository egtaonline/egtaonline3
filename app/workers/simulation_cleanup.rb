class SimulationCleanup
  include Sidekiq::Worker
  sidekiq_options queue: 'backend'

  def perform(simulation_id)
    ActiveRecord::Base.transaction do
      Backend.clean_simulation(simulation_id)
    end
  end
end
