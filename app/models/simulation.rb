class Simulation < ActiveRecord::Base
  validates_numericality_of :size, only_integer: true, greater_than: 0
  validates_inclusion_of :state, in: ['pending', 'queued', 'running', 'failed', 'processing', 'complete']

  belongs_to :profile, inverse_of: :simulations
  belongs_to :scheduler, inverse_of: :simulations

  delegate :assignment, to: :profile
  delegate :simulator_fullname, to: :profile

  def self.active_on_flux
    active.where(flux: true)
  end

  def self.active_on_other
    active.where(flux: false)
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
    self.update_attributes(state: 'processing')
    DataParser.perform_async(id, location)
  end

  def finish
    self.update_attributes(state: 'complete')
    requeue
  end

  def queue_as(jid)
    self.update_attributes(job_id: jid, state: 'queued')
  end

  def fail(message)
    self.update_attributes(error_message: message, state: 'failed')
    requeue
  end

  def requeue
    ProfileScheduler.perform_in(5.minutes, profile_id)
  end
end
