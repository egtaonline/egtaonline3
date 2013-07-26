class GamePresenter
  def initialize(game)
    @game = game
  end

  def to_json(options={})
    case options[:granularity]
    when "structure"
      @game.to_json
    when "full"
      DB.select_value(full)
    when "observations"
      DB.select_value(observations)
    else
      DB.select_value(summary)
    end
  end

  def explain(query)
    DB.execute("explain analyze "+query)
  end

  def summary
    sql = <<-SQL
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
          where role_owner_id = #{@game.id}
        ) role
      ) as roles,
      (
        select array_to_json(array_agg(profile))
        from (
          select profiles.id, observations_count, (
            select array_to_json(array_agg(symmetry_group))
            from (
              select symmetry_groups.id, role, strategy, count, avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd
              from symmetry_groups, players
              where players.symmetry_group_id = symmetry_groups.id and symmetry_groups.profile_id = profiles.id
              group by symmetry_groups.id
              order by symmetry_groups.id
            ) symmetry_group
          ) as symmetry_groups
          from profiles
          where simulator_instance_id=#{@game.simulator_instance_id} and assignment SIMILAR TO '#{@game.profile_space}' and observations_count > 0
          group by profiles.id
          order by assignment
        ) as profile
      ) as profiles
      from games, simulator_instances
      where games.id = #{@game.id} and games.simulator_instance_id = simulator_instances.id
      ) t
    SQL
  end

  def observations
    sql = <<-SQL
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
          where role_owner_id = #{@game.id}
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
              order by symmetry_groups.id
            ) symmetry_group
          ) as symmetry_groups,
          (
            select array_to_json(array_agg(observation))
            from (
              select features, (
                select array_to_json(array_agg(sg))
                from (
                  select symmetry_group_id as id, avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd
                  from players
                  where observation_id = observations.id
                  group by symmetry_group_id order by symmetry_group_id
                ) sg
              ) as symmetry_groups
              from observations
              where profile_id = profiles.id
            ) observation
          ) as observations
          from profiles
          where simulator_instance_id=#{@game.simulator_instance_id} and assignment SIMILAR TO '#{@game.profile_space}' and observations_count > 0
          group by profiles.id
          order by assignment
        ) as profile
      ) as profiles
      from games, simulator_instances
      where games.id = #{@game.id} and games.simulator_instance_id = simulator_instances.id
      ) t
    SQL
  end

  def full
    sql = <<-SQL
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
          where role_owner_id = #{@game.id}
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
              select features, (
                select array_to_json(array_agg(player))
                from (
                  select payoff, features, symmetry_group_id
                  from players
                  where observation_id = observations.id
                  order by symmetry_group_id
                ) player
              ) as players
              from observations
              where profile_id = profiles.id
            ) observation
          ) as observations
          from profiles
          where simulator_instance_id=#{@game.simulator_instance_id} and assignment SIMILAR TO '#{@game.profile_space}' and observations_count > 0
          group by profiles.id
          order by assignment
        ) as profile
      ) as profiles
      from games, simulator_instances
      where games.id = #{@game.id} and games.simulator_instance_id = simulator_instances.id
      ) t
    SQL
  end
end