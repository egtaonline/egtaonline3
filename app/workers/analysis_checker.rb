class AnalysisChecker
	include Sidekiq::Worker
	sidekiq_options queue: 'analysis'
	def perform
	    # ActiveRecord::Base.transaction do
	    #   Backend.update_simulations(Simulation.active)
	    # end
	end
end