class Analysis < ActiveRecord::Base
  extend Searchable
	
  belongs_to :game
  has_one :analysis_script, dependent: :destroy
  has_one :reduction_script, dependent: :destroy
  has_one :subgame_script, dependent: :destroy
  has_one :dominance_script, dependent: :destroy
  has_one :learning_script, dependent: :destroy
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

  private

  def self.general_search(search) # searches if any word matches game_id
    words = search.split(' ')
    if words.empty? # if empty search, everything returned
      return where("1=1")
    else
      return where(game_id: words)
    end
  end

  def self.column_filter(results, filters)
    if filters.key?("status")
      results = results.where("UPPER(status) = ?", filters["status"])
    end
    if filters.key?("game")
      results = results.where(game_id: filters["game"])
    end
    if filters.key?("folder_number")
      results = results.where(id: filters["folder_number"])
    end
    if filters.key?("job")
      results = results.where(job_id: filters["job"])
    end
    if filters.key?("time_created")
      results = results.where("CAST(created_at AS text) LIKE ?", "%#{filters["time_created"]}%")
    end
    return results
  end
end
