class ObservationAgg < ActiveRecord::Base
  belongs_to :observation, inverse_of: :observation_aggs
  belongs_to :symmetry_group, inverse_of: :observation_aggs,
                              counter_cache: true
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
    self.adjusted_payoff ||= 0
    self.adjusted_payoff_sd = payoffs['adjusted_payoff_sd']
  end

  after_create do
    sgroup = self.symmetry_group
    total_count = sgroup.observation_aggs_count + 1
    if total_count == 1
      symmetry_group.update_attributes(
        payoff: payoff,
        sum_sq_diff: 0,
        adjusted_payoff: adjusted_payoff,
        adj_sum_sq_diff: 0
      )
    else
      old_payoff = sgroup.payoff
      old_adj_payoff = sgroup.adjusted_payoff
      old_adj_sum_of_sq = sgroup.adj_sum_sq_diff
      if old_adj_payoff == nil
        sgroup.observation_aggs.where('adjusted_payoff IS NULL').each do |o|
          o.update_attributes(adjusted_payoff: o.payoff)
        end
        old_adj_payoff = sgroup.observation_aggs.where('id != ?', self.id)
          .average(:adjusted_payoff)
        old_adj_sum_of_sq = ObservationAgg.connection.select_all(
          "SELECT regr_sxx(adjusted_payoff, adjusted_payoff)
           FROM observation_aggs
           WHERE symmetry_group_id = #{sgroup.id}
           AND observation_aggs.id != #{self.id}")[0]["regr_sxx"].to_f
      end
      new_payoff = old_payoff + (payoff - old_payoff) / total_count
      sum_of_sq = sgroup.sum_sq_diff +
                  (payoff - old_payoff) * (payoff - new_payoff)
      new_adj_payoff = old_adj_payoff +
                       (adjusted_payoff - old_adj_payoff) / total_count
      adj_sum_of_sq = old_adj_sum_of_sq +
                      (adjusted_payoff - old_adj_payoff) *
                      (adjusted_payoff - new_adj_payoff)
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
