class Analysis < ActiveRecord::Base
	
	belongs_to :game
	has_one :analysis_script, dependent: :destroy
	has_one :reduction_script, dependent: :destroy
	has_one :subgame_script, dependent: :destroy
	has_one :dominance_script, dependent: :destroy
	has_one :pbs, dependent: :destroy

	
	def self.active
    	where(status: %w(queued running))
  	end

  	def self.queueable
    	where(status: 'pending').order('created_at ASC').limit(5)
  	end
	
	def self.stale(age = 300_000)
	    where('status IN (?) AND updated_at < ?',
	          %w(queued complete failed), Time.current - age)
  	end
  	
	def fail(message)
    	update_attributes(error_message: message[0..255], status: 'failed')
  	end	

  	def queue_as(jid)
    	update_attributes(job_id: jid, status: 'queued') if status == 'pending'
  	end

  	def start
    	update_attributes(status: 'running') if status == 'queued'
  	end

  	def process
	    if %w(queued running).include?(status)
	      ActiveRecord::Base.transaction do
	        update_attributes(status: 'processing')
	      end
	      AnalysisDataParser.perform_async(self.id)
	    end
  	end

  	def finish
	    unless status == 'failed'
	      logger.debug "Analysis #{id} moving to complete status"
	      update_attributes(status: 'complete')
	    end
 	end
end
