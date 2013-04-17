class Player < ActiveRecord::Base
  attr_accessible :features, :payoff
  serialize :features, ActiveRecord::Coders::Hstore

  validates :payoff, presence: true, numericality: true
  belongs_to :symmetry_group, inverse_of: :players
  belongs_to :observation, inverse_of: :players
end
