class Game < ActiveRecord::Base
  attr_accessible :name, :size
  serialize :role_configuration, JSON

  validates_presence_of :name, :size

  has_and_belongs_to_many :profiles
  belongs_to :simulator_instance, inverse_of: :games
end
