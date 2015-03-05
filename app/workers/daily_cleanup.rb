class DailyCleanup
  include Sidekiq::Worker
  sidekiq_options queue: 'backend'

  def perform
    ActiveRecord::Base.transaction do
      Simulation.stale.each do |s|
        SimulationCleanup.perform_async(s.id)
      end
      Analysis.stale.each do |a|
        AnalysisCleanup.perform_async(a.game_id, a.id)
      end
      Simulation.stale.delete_all
      #Analysis.stale.delete_all
      Simulation.recently_finished.each { |s| s.requeue }
      FileUtils.rm_rf(Dir.glob("#{Rails.root}/public/games/*"), secure: true)

      #clean analysis output files#{Rails.root}/public/analysis
    end
  end
end
