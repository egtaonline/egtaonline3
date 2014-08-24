class AnalysisRequeuer
	include Sidekiq::Worker
	sidekiq_options queue: 'analysis'
	def perform(analysis)
		AnalysisSubmitter.new(analysis).submit
	end
end