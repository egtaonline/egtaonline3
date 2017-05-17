class SchedulingRequirement < ActiveRecord::Base
  extend Searchable

  validates :count, presence: true, numericality: { only_integer: true }
  validates :scheduler, uniqueness: { scope: :profile }
  validates_presence_of :scheduler, :profile

  belongs_to :profile, inverse_of: :scheduling_requirements
  belongs_to :scheduler, inverse_of: :scheduling_requirements

  delegate :assignment, to: :profile
  delegate :observations_count, to: :profile

  after_save { profile.try_scheduling }

  private

  def self.general_search(search)
    return joins(:profile).where("UPPER(assignment) LIKE ?", "%#{search}%")
  end

  def self.column_filter(results, filters)
    if filters.key?("assignment")
      results = results.where("UPPER(assignment) LIKE ?", "%#{filters["assignment"]}%")
    end
    if filters.key?("requested_observations")
      results = results.where(count: filters["requested_observations"])
    end
    if filters.key?("observation_count") # different format since column is from the join
      results = results.where("observations_count = ?", filters["observation_count"])
    end
    return results
  end
end
