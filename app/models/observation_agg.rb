class ObservationAgg < ActiveRecord::Base
  belongs_to :observation
  belongs_to :symmetry_group
  validates_presence_of :observation, :symmetry_group
  before_validation(on: :create) do
    payoffs = Player.where(observation_id: observation_id, symmetry_group_id: symmetry_group_id).order("").group(:observation_id, :symmetry_group_id).select('avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd').first
    self.payoff = payoffs["payoff"]
    self.payoff_sd = payoffs["payoff_sd"]
  end
end