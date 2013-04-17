class SymmetryGroup < ActiveRecord::Base
  attr_accessible :count, :payoff, :payoff_sd, :profile_id, :role, :strategy
end
