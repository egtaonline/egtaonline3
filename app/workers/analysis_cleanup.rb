class AnalysisCleanup
  include Sidekiq::Worker
  sidekiq_options queue: 'analysis'

  def perform(game_id, analysis_id)
    ActiveRecord::Base.transaction do
      AnalysisCleaner.new(game_id, analysis_id).clean
    end
  end 
end