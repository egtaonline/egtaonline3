class Game < ActiveRecord::Base
  attr_accessible :name, :size, :simulator_instance_id

  validates_presence_of :name, :size

  belongs_to :simulator_instance, inverse_of: :games
  has_many :roles, as: :role_owner
  delegate :simulator_fullname, to: :simulator_instance
  delegate :configuration, to: :simulator_instance
end
