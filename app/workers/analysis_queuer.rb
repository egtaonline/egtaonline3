class AnalysisQueuer
	include Sidekiq::Worker
	sidekiq_options queue: 'analysis'
	def perform
		ActiveRecord::Base.transaction do
			to_be_queued = Analysis.queueable.to_a
			to_be_queued.each { |analysis| AnalysisPreparer.prepare_analysis(analysis) }
			to_be_queued.each { |analysis| AnalysisSubmitter.new(analysis).submit }
		end
	end
end