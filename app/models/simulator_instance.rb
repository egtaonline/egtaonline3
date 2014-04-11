class SimulatorInstance < ActiveRecord::Base
  belongs_to :simulator, inverse_of: :simulator_instances
  has_many :schedulers, dependent: :destroy, inverse_of: :simulator_instance
  has_many :profiles, dependent: :destroy, inverse_of: :simulator_instance
  has_many :games, dependent: :destroy, inverse_of: :simulator_instance
  has_many :control_variables, dependent: :delete_all, inverse_of: :simulator_instance
  has_many :player_control_variables, dependent: :delete_all, inverse_of: :simulator_instance
  has_one :control_variate_state, dependent: :destroy, inverse_of: :simulator_instance
  validates_presence_of :simulator_fullname, :simulator
  validates_uniqueness_of :configuration, scope: :simulator_id

  before_validation(on: :create) do
    self.simulator_fullname = simulator.fullname
    self.control_variate_state = ControlVariateState.new(state: 'none')
  end

  def self.find_or_create_for(simulator_id, configuration)
    configuration ||= {}
    configuration = configuration.collect { |key, value| "\"#{key}\" => \"#{value}\"" }.join(', ')
    simulator_instance = SimulatorInstance.where('simulator_id = ? AND configuration = (?)',
                                                 simulator_id, configuration).first
    simulator_instance || SimulatorInstance.create!(simulator_id: simulator_id,
                                                    configuration: configuration)
  end
end
