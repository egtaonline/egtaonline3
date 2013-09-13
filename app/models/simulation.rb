class Simulation < ActiveRecord::Base
  validates_numericality_of :size, only_integer: true, greater_than: 0
  validates_inclusion_of :state, in: ['pending', 'queued', 'running', 'failed', 'processing', 'complete']

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
    where(state: ['queued', 'running'])
  end

  def self.scheduled
    where(state: ['pending', 'queued', 'running'])
  end

  def start
    self.update_attributes(state: 'running') if self.state == 'queued'
  end

  def process(location)
    if ['queued', 'running'].include?(state)
      ActiveRecord::Base.transaction do
        self.update_attributes(state: 'processing')
      end
      DataParser.perform_async(id, location)
    end
  end

  def finish
    unless self.state == 'failed'
      logger.debug "Simulation #{id} moving to complete state"
      self.update_attributes(state: 'complete')
      logger.info "Rescheduling profile for simulation #{id}"
      requeue
    end
  end

  def queue_as(jid)
    self.update_attributes(job_id: jid, state: 'queued') if state == 'pending'
  end

  def fail(message)
    self.update_attributes(error_message: message, state: 'failed')
    requeue
  end

  def requeue
    ProfileScheduler.perform_in(5.minutes, profile_id)
  end

  def self.stale(age=300000)
    where("state IN (?) AND updated_at < ?",
      ['queued', 'complete', 'failed'], Time.current-age)
  end

  def self.recently_finished(age=86400)
    where("state IN (?) AND updated_at > ?",
      ['complete', 'failed'], Time.current-age)
  end

  def self.queueable
    where(state: 'pending').order('created_at ASC').limit(simulation_limit)
  end

  def self.simulation_limit
    [[Backend.queue_quantity,
      Backend.queue_max-Simulation.active.count].min, 0].max
  end
end
