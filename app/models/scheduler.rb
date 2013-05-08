class Scheduler < ActiveRecord::Base
  attr_accessible :active, :name, :nodes, :process_memory, :observations_per_simulation, :size, :time_per_observation,
                  :default_observation_requirement, :simulator_instance_id

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

  def self.create_with_simulator_instance(params)
    if params
      simulator_id = params.delete(:simulator_id)
      configuration = params.delete(:configuration)
      si = SimulatorInstance.where("simulator_id = ? AND configuration @> hstore(ARRAY[?])", simulator_id, configuration.to_a.flatten).first
      if si
        params[:simulator_instance_id] = si.id
      else
        params[:simulator_instance_id] = SimulatorInstance.create!(simulator_id: simulator_id, configuration: configuration).id
      end
    end
    create(params)
  end
  
  def add_strategy(role_name, strategy)
    role = self.roles.where(name: role_name).first
    if role
      role.strategies += [strategy]
      role.save!
      ProfileAssociator.perform_async(self.id)
    end
  end
  
  def remove_strategy(role_name, strategy)
    role = self.roles.where(name: role_name).first
    if role && role.strategies.include?(strategy)
      role.strategies -= [strategy]
      role.save!
      ProfileAssociator.perform_async(self.id)
    end
  end
  
  def add_role(role, count, reduced_count=count)
    if !self.roles.where(name: role).first
      self.roles.create!(name: role, count: count, reduced_count: reduced_count)
    end
  end
  
  def remove_role(role)
    self.roles.where(name: role).destroy_all
    ProfileAssociator.perform_async(self.id)
  end
  
  def unassigned_player_count
    roles.count == 0 ? size : size-roles.collect{ |r| r.count }.reduce(:+)
  end
  
  def available_roles
    simulator.role_configuration.keys - roles.collect{ |r| r.name }
  end
  
  def available_strategies(role)
    simulator.role_configuration[role] - self.roles.where(name: role).first.strategies
  end
  
  def invalid_role_partition?
    (roles.collect{ |role| role.count }.reduce(:+) != size) | roles.detect{ |r| r.strategies.count == 0 }
  end
  
  def schedule_profile(profile, required_count)
    observations_to_schedule = [observations_per_simulation, required_count-profile.observation_count].min
    self.simulations.create!(size: observations_to_schedule, state: 'pending',
                             profile_id: profile.id) if observations_to_schedule > 0
  end
end
