class Player < ActiveRecord::Base
  validates :payoff, presence: true, numericality: true
  belongs_to :symmetry_group, inverse_of: :players
  belongs_to :observation, inverse_of: :players
  validates_presence_of :symmetry_group, :observation
end
