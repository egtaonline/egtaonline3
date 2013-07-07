class DailyCleanup
  include Sidekiq::Worker

  def perform
    Simulation.stale.destroy_all
    Simulation.recently_finished.each { |s| s.requeue }
  end
end