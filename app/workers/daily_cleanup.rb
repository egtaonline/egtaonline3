class DailyCleanup
  include Sidekiq::Worker
  sidekiq_options queue: 'backend'

  def perform
    ActiveRecord::Base.transaction do
      Simulation.stale.destroy_all
      Simulation.recently_finished.each { |s| s.requeue }
    end
  end
end