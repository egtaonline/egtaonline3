class SymmetryGroup < ActiveRecord::Base
  attr_accessible :count, :payoff, :payoff_sd, :role, :strategy

  belongs_to :profile, inverse_of: :symmetry_groups

  validates_presence_of :role, :strategy, :count
  validates_numericality_of :count, only_integer: true, greater_than: 0
  validates_numericality_of :payoff, :payoff_sd
end
