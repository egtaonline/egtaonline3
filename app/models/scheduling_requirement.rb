class SchedulingRequirement < ActiveRecord::Base
  validates :count, presence: true, numericality: { only_integer: true }
  validates :scheduler, uniqueness: { scope: :profile }
  validates_presence_of :scheduler, :profile

  belongs_to :profile, inverse_of: :scheduling_requirements
  belongs_to :scheduler, inverse_of: :scheduling_requirements

  delegate :assignment, to: :profile
  delegate :observations_count, to: :profile

  after_save { profile.try_scheduling }

  def self.search(search)
    search.strip!
#    search.gsub!(" ", "%")
    search.gsub!(" ", "_")
    search.upcase!
    joins(:profile).where("UPPER(assignment) LIKE ?", "%#{search}%")
  end
end
