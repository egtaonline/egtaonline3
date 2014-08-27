class AnalysisChecker
	include Sidekiq::Worker
	sidekiq_options queue: 'high_concurrency'
	def perform
	    ActiveRecord::Base.transaction do
	      AnalysisUpdatter.update_analysis(Analysis.active)
	    end
	end
end