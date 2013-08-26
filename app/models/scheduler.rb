class Scheduler < ActiveRecord::Base
  include ProfileSpaces

  validates :name, presence: true, uniqueness: true
  validates_presence_of :process_memory, :nodes, :observations_per_simulation, :size, :time_per_observation, :simulator_instance
  validates_numericality_of :process_memory, :nodes, :observations_per_simulation, :size, :time_per_observation,
                            :default_observation_requirement, only_integer: true, greater_than: -1

  belongs_to :simulator_instance, inverse_of: :schedulers
  has_many :simulations, inverse_of: :scheduler
  has_many :scheduling_requirements, inverse_of: :scheduler, dependent: :destroy
  has_many :roles, as: :role_owner

  delegate :simulator_fullname, to: :simulator_instance
  delegate :simulator_id, to: :simulator_instance
  delegate :simulator, to: :simulator_instance
  delegate :configuration, to: :simulator_instance

  after_save :update_scheduling_requirements, on: :update, if: :update_conditions?
  after_save :try_scheduling, on: :update, if: :activated?

  def update_scheduling_requirements
    ProfileAssociator.perform_async(id)
  end

  def remove_role(role_name)
    super
    update_scheduling_requirements
  end

  def schedule_profile(profile, required_count)
    observations_to_schedule = [observations_per_simulation, required_count-profile.observations_count].min
    self.simulations.create!(size: observations_to_schedule, state: 'pending', profile_id: profile.id) if observations_to_schedule > 0
  end

  def try_scheduling
    scheduling_requirements.each do |s|
      s.profile.try_scheduling
    end
  end

  private

  def update_conditions?
    (simulator_instance_id_changed? && simulator_instance_id_was != nil) || (default_observation_requirement_changed? && default_observation_requirement_was != nil)
  end

  def activated?
    active_changed? && active == true
  end
end
