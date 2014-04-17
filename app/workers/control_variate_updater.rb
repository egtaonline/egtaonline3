class ControlVariateUpdater
  include Sidekiq::Worker
  sidekiq_options queue: 'profile_space'

  def perform(sim_instance_id, control_variables, player_control_variables)
    simulator_instance = SimulatorInstance.find(sim_instance_id)
    simulator_instance.control_variate_state.update_attributes(
      state: 'applying')
    # dumb way of ensuring against sql-injection since the rails way
    # doesn't seem to like the hstore commands
    instance_id = simulator_instance.id
    binds = []
    ActiveRecord::Base.exec_sql(
      "BEGIN ISOLATION LEVEL SERIALIZABLE;\n" +
      control_variables.map do |cv|
        binds.concat(
          [cv['coefficient'].to_f, cv['expectation'].to_f,
           cv['name'], instance_id])
        "UPDATE control_variables SET coefficient = ?, expectation = ? " \
        "WHERE name = ? AND simulator_instance_id = ?;\n"
      end.join('') +
      player_control_variables.map do |cv|
        binds.concat([cv['coefficient'].to_f, cv['expectation'].to_f,
                      cv['name'], instance_id, cv['role']])
        "UPDATE player_control_variables SET coefficient = ?, " \
        "expectation = ? WHERE name = ? AND simulator_instance_id = ? " \
        "AND role = ?;\n"
      end.join('') +
      'COMMIT;', *binds)
    DB.execute("
       WITH rel_cv AS (
         SELECT *
         FROM control_variables
         WHERE coefficient != 0
         AND simulator_instance_id = #{instance_id}),
       rel_pcv AS (
         SELECT *
         FROM player_control_variables
         WHERE coefficient != 0
         AND simulator_instance_id = #{instance_id}),
       cv_keys AS (
         SELECT array_agg(name) as keys
         FROM rel_cv),
       pcv_keys AS (
         SELECT role, array_agg(name) as keys
         FROM rel_pcv
         GROUP BY role),
       rel_observations AS (
         SELECT observations.id, features
         FROM observations
         JOIN profiles ON (observations.profile_id = profiles.id)
         WHERE profiles.simulator_instance_id = #{instance_id}),
       rel_players AS (
         SELECT players.id, observation_id, players.features, role
         FROM players, rel_observations, symmetry_groups
         WHERE players.observation_id = rel_observations.id
         AND players.symmetry_group_id = symmetry_groups.id),
       obs_features AS (
         SELECT id as observation_id, f.key as name, f.value
         FROM rel_observations, LATERAL each(features) f, cv_keys
         WHERE features ?& cv_keys.keys),
       obs_adjust AS (
         SELECT observation_id,
           coefficient * (value::float - expectation) AS adjustment
         FROM rel_cv JOIN obs_features USING (name)),
       sum_obs AS (
         SELECT observation_id, sum(adjustment) AS o_adjustment
         FROM obs_adjust
         GROUP BY observation_id),
       player_features AS (
         SELECT id, observation_id, rel_players.role, f.key as name, f.value
         FROM pcv_keys, rel_players, LATERAL each(features) f
         WHERE features ?& pcv_keys.keys
         AND pcv_keys.role = rel_players.role),
       player_data AS (
         SELECT observation_id, player_features.id,
           coefficient * (value::float - expectation) AS adjustment
         FROM rel_pcv JOIN player_features USING (role, name)),
       adjustments AS (
         SELECT id, sum(adjustment) + o_adjustment AS adjustment
         FROM player_data JOIN sum_obs USING (observation_id)
         GROUP BY id, o_adjustment),
       f_adjustment AS (
         SELECT id, adjustment
         FROM rel_players LEFT JOIN adjustments USING (id))
       UPDATE players SET adjusted_payoff = (
         CASE WHEN adjustment IS NULL THEN payoff
         ELSE payoff + adjustment END)
       FROM f_adjustment
       WHERE f_adjustment.id = players.id")
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
