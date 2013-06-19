class SchedulingRequirement < ActiveRecord::Base
  validates :count, presence: true, numericality: { only_integer: true }
  validates_uniqueness_of :scheduler_id, scope: :profile_id

  belongs_to :profile, inverse_of: :scheduling_requirements
  belongs_to :scheduler, inverse_of: :scheduling_requirements

  delegate :assignment, to: :profile
  delegate :observations_count, to: :profile
end
