class AnalysisRequeuer
	include Sidekiq::Worker
	sidekiq_options queue: 'analysis'
	def perform(analysis)
		# analysis.update_attributes( status: 'pending')
		AnalysisSubmitter.new(analysis).submit
	end
end