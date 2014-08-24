class Analysis < ActiveRecord::Base
	
	belongs_to :game
	has_one :analysis_script, dependent: :destroy
	has_one :reduction_script, dependent: :destroy
	has_one :subgame_script, dependent: :destroy
	has_one :dominance_script, dependent: :destroy
	has_one :pbs, dependent: :destroy

	scope :queueable, where(status: "pending").order('created_at ASC').limit(5)
	def fail(message)
    	update_attributes(error_message: message[0..255], status: 'failed')
    	requeue
  	end	

  	def requeue
    	AnalysisRequeuer.perform_in(5.minutes,self)
  	end

  	def queue_as(jid)
    	update_attributes(job_id: jid, status: 'queued') if status == 'pending'
  	end
end
