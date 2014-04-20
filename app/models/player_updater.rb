class PlayerUpdater
  def self.update(instance_id)
    DB.execute("
       WITH rel_cv AS (
         SELECT name, role, coefficient, expectation
         FROM control_variables JOIN role_coefficients
           ON (control_variables.id = role_coefficients.control_variable_id)
         WHERE coefficient != 0
         AND simulator_instance_id = #{instance_id}),
       rel_pcv AS (
         SELECT name, role, coefficient, expectation
         FROM player_control_variables
         WHERE coefficient != 0
         AND simulator_instance_id = #{instance_id}),
       cv_keys AS (
         SELECT array_agg(DISTINCT name) as keys
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
         SELECT observation_id, role,
           coefficient * (value::float - expectation) AS adjustment
         FROM rel_cv JOIN obs_features USING (name)),
       sum_obs AS (
         SELECT observation_id, role, sum(adjustment) AS o_adjustment
         FROM obs_adjust
         GROUP BY observation_id, role),
       player_features AS (
         SELECT id, observation_id, rel_players.role, f.key as name, f.value
         FROM pcv_keys, rel_players, LATERAL each(features) f
         WHERE features ?& pcv_keys.keys
         AND pcv_keys.role = rel_players.role),
       player_data AS (
         SELECT observation_id, player_features.id, role,
           coefficient * (value::float - expectation) AS adjustment
         FROM rel_pcv JOIN player_features USING (role, name)),
       adjustments AS (
         SELECT id, sum(adjustment) + o_adjustment AS adjustment
         FROM player_data JOIN sum_obs USING (observation_id, role)
         GROUP BY id, o_adjustment),
       f_adjustment AS (
         SELECT id, adjustment
         FROM rel_players LEFT JOIN adjustments USING (id))
       UPDATE players SET adjusted_payoff = (
         CASE WHEN adjustment IS NULL THEN payoff
         ELSE payoff + adjustment END)
       FROM f_adjustment
       WHERE f_adjustment.id = players.id")
  end
end
