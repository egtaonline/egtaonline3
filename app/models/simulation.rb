class Simulation < ActiveRecord::Base
  validates_numericality_of :size, only_integer: true, greater_than: 0
  validates_inclusion_of :state, in: %w(pending queued running failed processing complete)

  belongs_to :profile, inverse_of: :simulations
  belongs_to :scheduler, inverse_of: :simulations

  validates_presence_of :profile, :scheduler

  delegate :assignment, to: :profile
  delegate :simulator_fullname, to: :profile

  def self.active_on_flux
    active.where(qos: 'flux')
  end

  def self.active_on_other
    active.where.not(qos: 'flux')
  end

  def self.active
    where(state: %w(queued running))
  end

  def self.scheduled
    where(state: %w(pending queued running))
  end

  def start
    update_attributes(state: 'running') if state == 'queued'
  end

  def process(location)
    if %w(queued running).include?(state)
      ActiveRecord::Base.transaction do
        update_attributes(state: 'processing')
      end
      DataParser.perform_async(id, location)
    end
  end

  def finish
    unless state == 'failed'
      logger.debug "Simulation #{id} moving to complete state"
      update_attributes(state: 'complete')
      logger.info "Rescheduling profile for simulation #{id}"
      requeue
    end
  end

  def queue_as(jid)
    update_attributes(job_id: jid, state: 'queued') if state == 'pending'
  end

  def fail(message)
    update_attributes(error_message: message[0..255], state: 'failed')
    requeue
  end

  def requeue
    ProfileScheduler.perform_in(5.minutes, profile_id)
  end

  def self.stale(age = 300000)
    where('state IN (?) AND updated_at < ?',
      %w(queued complete failed), Time.current - age)
  end

  def self.recently_finished(age = 86400)
    where('state IN (?) AND updated_at > ?',
      %w(complete failed), Time.current - age)
  end

  def self.queueable
    where(state: 'pending').order('created_at ASC').limit(simulation_limit)
  end

  def self.simulation_limit
    [[Backend.queue_quantity,
      Backend.queue_max - Simulation.active.count].min, 0].max
  end
end
