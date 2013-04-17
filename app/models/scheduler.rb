class Scheduler < ActiveRecord::Base
  attr_accessible :active, :name, :nodes, :process_memory, :samples_per_simulation, :size, :time_per_sample
  serialize :role_configuration, ActiveRecord::Coders::Hstore

  validates :name, presence: true, uniqueness: true
  validates_presence_of :process_memory, :nodes, :samples_per_simulation, :size, :time_per_sample
  validates_numericality_of :process_memory, :nodes, :samples_per_simulation, :size, :time_per_sample, only_integer: true, greater_than: 0

  belongs_to :simulator_instance, inverse_of: :schedulers
  has_many :simulations, inverse_of: :scheduler
  has_many :scheduling_requirements, inverse_of: :scheduler, dependent: :destroy
end
