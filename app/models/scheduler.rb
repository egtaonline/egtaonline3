class Scheduler < ActiveRecord::Base
  include ProfileSpaces

  validates :name, presence: true, uniqueness: true
  validates_presence_of :process_memory, :nodes, :observations_per_simulation, :size, :time_per_observation
  validates_numericality_of :process_memory, :nodes, :observations_per_simulation, :size, :time_per_observation,
                            :default_observation_requirement, only_integer: true, greater_than: 0

  belongs_to :simulator_instance, inverse_of: :schedulers
  has_many :simulations, inverse_of: :scheduler
  has_many :scheduling_requirements, inverse_of: :scheduler, dependent: :destroy
  has_many :roles, as: :role_owner

  delegate :simulator_fullname, to: :simulator_instance
  delegate :simulator, to: :simulator_instance
  delegate :configuration, to: :simulator_instance

  after_save :update_scheduling_requirements, on: :update, if: :simulator_instance_was_changed?

  def update_scheduling_requirements
    ProfileAssociator.perform_async(id)
  end

  def add_strategy(role_name, strategy)
    role = self.roles.where(name: role_name).first
    if role
      role.strategies += [strategy]
      role.strategies.uniq!
      role.save!
      update_scheduling_requirements
    end
  end

  def remove_strategy(role_name, strategy)
    role = self.roles.where(name: role_name).first
    if role && role.strategies.include?(strategy)
      role.strategies -= [strategy]
      role.save!
      update_scheduling_requirements
    end
  end

  def remove_role(role_name)
    super
    update_scheduling_requirements
  end

  def invalid_role_partition?
    (roles.collect{ |role| role.count }.reduce(:+) != size) | roles.detect{ |r| r.strategies.count == 0 }
  end

  def schedule_profile(profile, required_count)
    observations_to_schedule = [observations_per_simulation, required_count-profile.observations_count].min
    self.simulations.create!(size: observations_to_schedule, state: 'pending',
                             profile_id: profile.id) if observations_to_schedule > 0
  end

  private

  def simulator_instance_was_changed?
    simulator_instance_id_changed? && simulator_instance_id_was != nil
  end
end
