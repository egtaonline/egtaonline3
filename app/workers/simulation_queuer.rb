class SimulationQueuer
  include Sidekiq::Worker
  sidekiq_options queue: 'backend'

  def perform
    ActiveRecord::Base.transaction do
      to_be_queued = Simulation.queueable.to_a
      to_be_queued.each { |sim| Backend.prepare_simulation(sim) }
      to_be_queued.each { |sim| Backend.schedule_simulation(sim) }
    end
  end
end
