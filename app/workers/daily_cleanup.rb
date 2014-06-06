class DailyCleanup
  include Sidekiq::Worker
  sidekiq_options queue: 'backend'

  def perform
    ActiveRecord::Base.transaction do
      Simulation.stale.each do |s|
        SimulationCleanup.perform_async(s.id)
      end
      Simulation.stale.delete_all
      Simulation.recently_finished.each { |s| s.requeue }
      FileUtils.rm_rf(Dir.glob("#{Rails.root}/public/games/*"), secure: true)
    end
  end
end
