class SimulatorInstance < ActiveRecord::Base
  attr_accessible :configuration
  serialize :configuration, ActiveRecord::Coders::Hstore

  belongs_to :simulator, inverse_of: :simulator_instances
  has_many :schedulers, dependent: :destroy, inverse_of: :simulator_instance
  has_many :profiles, dependent: :destroy, inverse_of: :simulator_instance
  has_many :games, dependent: :destroy, inverse_of: :simulator_instance

  validates_presence_of :simulator_fullname

  before_validation(on: :create){ self.simulator_fullname = simulator.fullname }
end
