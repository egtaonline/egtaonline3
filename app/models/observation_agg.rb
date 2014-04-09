class ObservationAgg < ActiveRecord::Base
  belongs_to :observation
  belongs_to :symmetry_group
  validates_presence_of :observation, :symmetry_group
  before_validation(on: :create) do
    payoffs = Player.where(observation_id: observation_id, symmetry_group_id: symmetry_group_id).order("").group(:observation_id, :symmetry_group_id).select('
      avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd, avg(adjusted_payoff) as adjusted_payoff, stddev_samp(adjusted_payoff) as adjusted_payoff_sd').first
    self.payoff = payoffs["payoff"]
    self.payoff_sd = payoffs["payoff_sd"]
    self.adjusted_payoff = payoffs["adjusted_payoff"]
    self.adjusted_payoff_sd = payoffs["adjusted_payoff_sd"]
  end
end