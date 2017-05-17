class Scheduler < ActiveRecord::Base
  include ProfileSpaces
  extend Searchable

  validates :name, presence: true, uniqueness: true
  validates_presence_of :process_memory, :nodes, :observations_per_simulation,
                        :size, :time_per_observation, :simulator_instance
  validates_numericality_of :process_memory, :nodes,
                            :observations_per_simulation, :size,
                            :time_per_observation,
                            :default_observation_requirement,
                            only_integer: true, greater_than: -1

  belongs_to :simulator_instance, inverse_of: :schedulers
  has_many :simulations, inverse_of: :scheduler
  has_many :scheduling_requirements, inverse_of: :scheduler,
                                     dependent: :delete_all
  has_many :roles, as: :role_owner

  delegate :simulator_fullname, to: :simulator_instance
  delegate :simulator_id, to: :simulator_instance
  delegate :simulator, to: :simulator_instance
  delegate :configuration, to: :simulator_instance

  after_save :update_requirements, on: :update, if: :update_conditions?
  after_save :try_scheduling, on: :update, if: :activated?
  after_save :reset_roles, on: :update, if: :size_changed?

  def reset_roles
    roles.destroy_all
  end

  def update_requirements
    ProfileAssociator.perform_async(id)
  end

  def remove_role(role_name)
    super
    update_requirements
  end

  def schedule_profile(profile, required)
    observations_to_schedule = [observations_per_simulation,
                                required - profile.observations_count].min
    simulations.create!(
      size: observations_to_schedule, state: 'pending',
      profile_id: profile.id) if observations_to_schedule > 0
  end

  def try_scheduling
    scheduling_requirements.each do |s|
      s.profile.try_scheduling
    end
  end

  private

  def update_conditions?
    simulator_instance_id_changed? ||
      default_observation_requirement_changed? || size_changed?
  end

  def activated?
    active_changed? && active == true
  end

  def self.general_search(search)
    return name_search(search)
  end

  def self.column_filter(results, filters)
    if filters.key?("name")
      results = name_filter(results, filters["name"])
    end
    if filters.key?("type")
      results = results.where("UPPER(type) = ?", filters["type"])
    end
    if filters.key?("simulator")
      results = results.joins(:simulator_instance).where("UPPER(simulator_fullname) LIKE ?", "%#{filters["simulator"]}%")
    end
    if filters.key?("active?")
      if filters["active?"] == "YES"
        results = results.where(active: true)
      elsif filters["active?"] == "NO"
        results = results.where(active: false)
      end
    end
    return results
  end
end
