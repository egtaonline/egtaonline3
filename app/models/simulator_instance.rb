class SimulatorInstance < ActiveRecord::Base
  attr_accessible :configuration
  has_many :schedulers, dependent: :destroy, inverse_of: :simulator_instance
end
