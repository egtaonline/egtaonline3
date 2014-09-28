class AnalysisDataParser
  include Sidekiq::Worker
  sidekiq_options queue: 'high_concurrency'

  def perform(analysis_id)
  	analysis = Analysis.find(analysis_id)
    unless analysis.status == 'complete'
      AnalysisDataProcessor.new(analysis).process_files
    end
  end
end
