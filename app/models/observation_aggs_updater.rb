class ObservationAggsUpdater
  def self.update(instance_id)
    DB.execute(
      "UPDATE observation_aggs
       SET adjusted_payoff = aggs.payoff,
         adjusted_payoff_sd = aggs.payoff_sd
       FROM (
         SELECT symmetry_group_id, observation_id,
           avg(adjusted_payoff) as payoff,
           stddev_samp(adjusted_payoff) as payoff_sd
         FROM players, observations, profiles
         WHERE players.observation_id = observations.id
         AND observations.profile_id = profiles.id
         AND profiles.simulator_instance_id = #{instance_id}
         GROUP BY symmetry_group_id, observation_id
       ) aggs
       WHERE aggs.symmetry_group_id = observation_aggs.symmetry_group_id
       AND aggs.observation_id = observation_aggs.observation_id")
  end
end
