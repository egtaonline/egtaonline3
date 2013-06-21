class Simulation < ActiveRecord::Base
  validates_numericality_of :size, only_integer: true, greater_than: 0
  validates_inclusion_of :state, in: ['pending', 'queued', 'running', 'failed', 'processing', 'complete']

  belongs_to :profile, inverse_of: :simulations
  belongs_to :scheduler, inverse_of: :simulations

  delegate :assignment, to: :profile
  delegate :simulator_fullname, to: :profile

  def self.scheduled
    where(state: ['pending', 'queued', 'running'])
  end
end
