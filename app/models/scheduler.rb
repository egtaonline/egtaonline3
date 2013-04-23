class Scheduler < ActiveRecord::Base
  attr_accessible :active, :name, :nodes, :process_memory, :observations_per_simulation, :size, :time_per_observation,
                  :default_observation_requirement, :simulator_instance_id
  serialize :role_configuration, JSON

  validates :name, presence: true, uniqueness: true
  validates_presence_of :process_memory, :nodes, :observations_per_simulation, :size, :time_per_observation
  validates_numericality_of :process_memory, :nodes, :observations_per_simulation, :size, :time_per_observation,
                            :default_observation_requirement, only_integer: true, greater_than: 0

  belongs_to :simulator_instance, inverse_of: :schedulers
  has_many :simulations, inverse_of: :scheduler
  has_many :scheduling_requirements, inverse_of: :scheduler, dependent: :destroy

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
  
  def add_strategy(role, strategy)
    self.role_configuration[role]['strategies'] << strategy
    self.save!
  end
  
  def remove_strategy(role, strategy)
    self.role_configuration[role]['strategies'].delete(strategy)
    self.save!
  end
  
  def add_role(role, count)
    self.role_configuration[role] ||= { 'count' => count, 'strategies' => [] }
    self.save!
  end
  
  def remove_role(role)
    self.role_configuration.delete(role)
    self.save!
  end
  
  def unassigned_player_count
    role_configuration == {} ? size : size-role_configuration.collect{ |k,v| v["count"] }.reduce(:+)
  end
  
  def available_roles
    simulator.role_configuration.keys - role_configuration.keys
  end
  
  def available_strategies(role)
    simulator.role_configuration[role] - role_configuration[role]['strategies']
  end
end
