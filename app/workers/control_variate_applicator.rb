class ControlVariateApplicator
  include Sidekiq::Worker
  sidekiq_options queue: 'profile_space'

  def perform(sim_instance_id, control_variables, player_control_variables)
    simulator_instance = SimulatorInstance.find(sim_instance_id)
    simulator_instance.control_variate_state.update_attributes(
      state: 'applying')
    # dumb way of ensuring against sql-injection since the rails way
    # doesn't seem to like the hstore commands
    instance_id = simulator_instance.id
    ControlVariateUpdater.update(control_variables, player_control_variables)
    PlayerUpdater.update(instance_id)
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
    DB.execute(
      "UPDATE symmetry_groups
       SET payoff = aggs.payoff, payoff_sd = aggs.payoff_sd,
         adjusted_payoff = aggs.adjusted_payoff,
         adjusted_payoff_sd = aggs.adjusted_payoff_sd
       FROM (
         SELECT avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd,
           avg(adjusted_payoff) as adjusted_payoff,
           stddev_samp(adjusted_payoff_sd) as adjusted_payoff_sd,
           symmetry_group_id
         FROM observation_aggs
         GROUP BY symmetry_group_id) AS aggs, profiles
       WHERE symmetry_groups.id = aggs.symmetry_group_id
       AND symmetry_groups.profile_id = profiles.id
       AND profiles.simulator_instance_id = #{instance_id}")
    simulator_instance.control_variate_state.update_attributes(
      state: 'complete')
  end
end
