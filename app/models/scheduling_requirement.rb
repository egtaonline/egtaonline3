class SchedulingRequirement < ActiveRecord::Base
  attr_accessible :count

  validates :count, presence: true, numericality: { only_integer: true }
  validates_uniqueness_of :scheduler_id, scope: :profile_id

  belongs_to :profile, inverse_of: :scheduling_requirement
  belongs_to :scheduler, inverse_of: :scheduling_requirement
end
