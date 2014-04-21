class SymmetryAdjPayoffUpdater
  def self.update(instance_id)
    DB.execute(
      "UPDATE symmetry_groups
       SET adjusted_payoff = aggs.adjusted_payoff,
           adjusted_payoff_sd = aggs.adjusted_payoff_sd
       FROM (
         SELECT avg(adjusted_payoff) as adjusted_payoff,
           stddev_samp(adjusted_payoff_sd) as adjusted_payoff_sd,
           symmetry_group_id
         FROM observation_aggs
         GROUP BY symmetry_group_id) AS aggs, profiles
       WHERE symmetry_groups.id = aggs.symmetry_group_id
       AND symmetry_groups.profile_id = profiles.id
       AND profiles.simulator_instance_id = #{instance_id}")
  end
end
