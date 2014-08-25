class AnalysisDataParser
  include Sidekiq::Worker
  sidekiq_options queue: 'high_concurrency'

  def perform(analysis)
    unless analysis.state == 'complete'
      AnalysisDataProcessor.new(analysis).process_files
    end
  end
end
