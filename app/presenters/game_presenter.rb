class GamePresenter
  def initialize(game)
    @game = game
  end

  def to_json(options = {})
    case options[:granularity]
    when 'structure'
      File.open("#{Rails.root}/public/games/#{@game.id}-structure.json", 'w') do |f|
        f.write(MultiJson.dump(@game.to_json))
      end
      "#{Rails.root}/public/games/#{@game.id}-structure.json"
    when 'full'
      DB.execute(full)
      "#{Rails.root}/public/games/#{@game.id}-full.json"
    when 'observations'
      DB.execute(observations)
      "#{Rails.root}/public/games/#{@game.id}-observations.json"
    else
      DB.execute(summary)
      "#{Rails.root}/public/games/#{@game.id}-summary.json"
    end
  end

  def explain(query)
    DB.execute('explain analyze ' + query)
  end

  def summary
    'COPY (' +
    profile_set +
      "select row_to_json(t)
      from (
      select games.id, games.name, simulator_instances.simulator_fullname,
      (
        hstore_to_matrix(configuration)
      ) as configuration,
      (
        select array_to_json(array_agg(role))
        from (
          select name, strategies, count
          from roles
          where role_owner_id = #{@game.id} AND role_owner_type = 'Game'
        ) role
      ) as roles,
      (
        select array_to_json(array_agg(profile))
        from (
          select profiles.id, observations_count, (
            select array_to_json(array_agg(symmetry_group))
            from (
              select symmetry_groups.id, role, strategy, count, symmetry_groups.payoff, symmetry_groups.payoff_sd
              from symmetry_groups
              where profile_id = profiles.id
            ) symmetry_group
          ) as symmetry_groups
          from profiles, result
          where profiles.id = result.profile_id
          group by profiles.id
        ) as profile
      ) as profiles
      from games, simulator_instances
      where games.id = #{@game.id} and games.simulator_instance_id = simulator_instances.id
      ) t) to '#{Rails.root}/public/games/#{@game.id}-summary.json';"
  end

  def observations
    'COPY (' +
    profile_set + "
      select row_to_json(t)
      from (
      select games.id, games.name, simulator_instances.simulator_fullname,
      (
        hstore_to_matrix(configuration)
      ) as configuration,
      (
        select array_to_json(array_agg(role))
        from (
          select name, strategies, count
          from roles
          where role_owner_id = #{@game.id} AND role_owner_type = 'Game'
        ) role
      ) as roles,
      (
        select array_to_json(array_agg(profile))
        from (
          select profiles.id, (
            select array_to_json(array_agg(symmetry_group))
            from (
              select symmetry_groups.id, role, strategy, count
              from symmetry_groups
              where profile_id = profiles.id
            ) symmetry_group
          ) as symmetry_groups,
          (
            select array_to_json(array_agg(observation))
            from (
              select features, extended_features, (
                select array_to_json(array_agg(sg))
                from (
                  select symmetry_group_id as id, payoff, payoff_sd
                  from observation_aggs
                  where observation_id = observations.id
                ) sg
              ) as symmetry_groups
              from observations
              where profile_id = profiles.id
            ) observation
          ) as observations
          from profiles, result
          where profiles.id = result.profile_id
          group by profiles.id
        ) as profile
      ) as profiles
      from games, simulator_instances
      where games.id = #{@game.id} and games.simulator_instance_id = simulator_instances.id
      ) t) to '#{Rails.root}/public/games/#{@game.id}-observations.json';"
  end

  def full
    'COPY (' +
    profile_set + "
      select row_to_json(t)
      from (
      select games.id, games.name, simulator_instances.simulator_fullname,
      (
        hstore_to_matrix(configuration)
      ) as configuration,
      (
        select array_to_json(array_agg(role))
        from (
          select name, strategies, count
          from roles
          where role_owner_id = #{@game.id} AND role_owner_type = 'Game'
        ) role
      ) as roles,
      (
        select array_to_json(array_agg(profile))
        from (
          select id, (
            select array_to_json(array_agg(symmetry_group))
            from (
              select symmetry_groups.id, role, strategy, count
              from symmetry_groups
              where profile_id = profiles.id
            ) symmetry_group
          ) as symmetry_groups,
          (
            select array_to_json(array_agg(observation))
            from (
              select features, extended_features, (
                select array_to_json(array_agg(player))
                from (
                  select payoff as p, features as f, extended_features as e, symmetry_group_id as sid
                  from players
                  where observation_id = observations.id
                ) player
              ) as players
              from observations
              where profile_id = profiles.id
            ) observation
          ) as observations
          from profiles, result
          where profiles.id = result.profile_id
          group by profiles.id
        ) as profile
      ) as profiles
      from games, simulator_instances
      where games.id = #{@game.id} and games.simulator_instance_id = simulator_instances.id
      ) t) to '#{Rails.root}/public/games/#{@game.id}-full.json';"
  end

  private

  def profile_set
    if @game.invalid_role_partition?
      'WITH result AS (SELECT id as profile_id FROM profiles WHERE id = 0)'
    else
      "WITH reasonable_profiles AS (
        SELECT symmetry_groups.id, symmetry_groups.profile_id, symmetry_groups.role, symmetry_groups.strategy, profiles.observations_count
        FROM symmetry_groups, profiles
        WHERE symmetry_groups.profile_id = profiles.id AND profiles.simulator_instance_id = #{@game.simulator_instance_id} AND profiles.role_configuration @> #{@game.role_configuration} AND profiles.observations_count > 0),
        out_space AS (SELECT * FROM reasonable_profiles WHERE NOT #{@game.profile_space}),
        result AS (SELECT DISTINCT ON(profile_id) profile_id FROM reasonable_profiles WHERE profile_id NOT IN (SELECT DISTINCT ON(profile_id) profile_id FROM out_space))"
    end
  end
end