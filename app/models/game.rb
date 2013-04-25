class Game < ActiveRecord::Base
  attr_accessible :name, :size

  validates_presence_of :name, :size

  has_and_belongs_to_many :profiles
  belongs_to :simulator_instance, inverse_of: :games
  has_many :roles, as: :role_owner
end
