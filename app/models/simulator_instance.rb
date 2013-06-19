class SimulatorInstance < ActiveRecord::Base
  belongs_to :simulator, inverse_of: :simulator_instances
  has_many :schedulers, dependent: :destroy, inverse_of: :simulator_instance
  has_many :profiles, dependent: :destroy, inverse_of: :simulator_instance
  has_many :games, dependent: :destroy, inverse_of: :simulator_instance

  validates_presence_of :simulator_fullname
  validates_uniqueness_of :configuration, scope: :simulator_id

  before_validation(on: :create){ self.simulator_fullname = simulator.fullname }
end
