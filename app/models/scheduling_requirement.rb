class SchedulingRequirement < ActiveRecord::Base
  validates :count, presence: true, numericality: { only_integer: true }
  validates :scheduler, uniqueness: { scope: :profile }
  validates_presence_of :scheduler, :profile

  belongs_to :profile, inverse_of: :scheduling_requirements
  belongs_to :scheduler, inverse_of: :scheduling_requirements

  delegate :assignment, to: :profile
  delegate :observations_count, to: :profile
end
