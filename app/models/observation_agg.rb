class ObservationAgg < ActiveRecord::Base
  belongs_to :observation
  belongs_to :symmetry_group
  validates_presence_of :observation, :symmetry_group
  before_validation(on: :create) do
    payoffs = Player.where(
      observation_id: observation_id, symmetry_group_id: symmetry_group_id)
      .order('').group(:observation_id, :symmetry_group_id).select(
      'avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd, ' \
      'avg(adjusted_payoff) as adjusted_payoff, stddev_samp(adjusted_payoff)' \
      ' as adjusted_payoff_sd').first
    self.payoff = payoffs['payoff']
    self.payoff_sd = payoffs['payoff_sd']
    self.adjusted_payoff = payoffs['adjusted_payoff']
    self.adjusted_payoff_sd = payoffs['adjusted_payoff_sd']
  end

  after_create do
    total_count = self.symmetry_group.observation_aggs.count
    if total_count == 1
      symmetry_group.update_attributes(
        payoff: payoff,
        sum_sq_diff: 0,
        adjusted_payoff: adjusted_payoff,
        adj_sum_sq_diff: 0
      )
    else
      t = Time.now
      sgroup = self.symmetry_group
      puts "Spent #{Time.now-t} acquiring sgroup"
      t = Time.now
      old_payoff = sgroup.payoff
      old_adj_payoff = sgroup.adjusted_payoff
      new_payoff = old_payoff + (payoff - old_payoff) / total_count
      sum_of_sq = sgroup.sum_sq_diff +
                  (payoff - old_payoff) * (payoff - new_payoff)
      new_adj_payoff = old_adj_payoff +
                       (adjusted_payoff - old_adj_payoff) / total_count
      adj_sum_of_sq = sgroup.adj_sum_sq_diff +
                      (adjusted_payoff - old_adj_payoff) *
                      (adjusted_payoff - new_adj_payoff)
      puts "Spent #{Time.now-t} doing math"
      sgroup.update_attributes(
        payoff: new_payoff,
        payoff_sd: Math.sqrt(sum_of_sq / (total_count - 1)),
        sum_sq_diff: sum_of_sq,
        adjusted_payoff: new_adj_payoff,
        adjusted_payoff_sd: Math.sqrt(adj_sum_of_sq / (total_count - 1)),
        adj_sum_sq_diff: adj_sum_of_sq)
    end
  end
end
