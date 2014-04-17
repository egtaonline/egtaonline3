class AggregateUpdater
  def self.update(observations, profile)
    profile.symmetry_groups.each do |sgroup|
      observations.each do |observation|
        observation.observation_aggs.create!(symmetry_group_id: sgroup.id)
      end
    end
    ActiveRecord::Base.exec_sql(
      'UPDATE symmetry_groups
       SET payoff = aggs.payoff, payoff_sd = aggs.payoff_sd,
         adjusted_payoff = aggs.adjusted_payoff,
         adjusted_payoff_sd = aggs.adjusted_payoff_sd
       FROM (
         SELECT avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd,
           avg(adjusted_payoff) as adjusted_payoff,
           stddev_samp(adjusted_payoff_sd) as adjusted_payoff_sd,
           symmetry_group_id
         FROM observation_aggs
         GROUP BY symmetry_group_id) AS aggs
       WHERE symmetry_groups.id = aggs.symmetry_group_id
       AND profile_id = ?', profile.id)
  end
end
