class GamePresenter
  def initialize(game)
    @game = game
  end

  def to_json(options={})
    case options[:granularity]
    when "structure"
      structure
    when "full"
      DB.select_value(full)
    when "observations"
      DB.select_value(observations)
    else
      summary
    end
  end


  def explain(query)
    DB.execute("explain analyze "+query)
  end

  def summary

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
            ) symmetry_group
          ) as symmetry_groups,
          (
            select array_to_json(array_agg(observation))
            from (
              select (
                hstore_to_matrix(features)
              ) as features, (
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
          where simulator_instance_id=#{@game.simulator_instance_id} and observations_count > 0 and assignment = any('#{@game.profile_space.to_s.gsub(/\[(.*)\]/, '{\1}')}'::text[])
          group by profiles.id
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
              select (
                hstore_to_matrix(features)
              ) as features, (
                select array_to_json(array_agg(player))
                from (
                  select payoff, (
                  hstore_to_matrix(features)
                  ) as features, symmetry_group_id
                  from players
                  where observation_id = observations.id
                ) player
              ) as players
              from observations
              where profile_id = profiles.id
            ) observation
          ) as observations
          from profiles
          where simulator_instance_id=#{@game.simulator_instance_id} and assignment = any('#{@game.profile_space.to_s.gsub(/\[(.*)\]/, '{\1}')}'::text[])
          group by profiles.id
        ) as profile
      ) as profiles
      from games, simulator_instances
      where games.id = #{@game.id} and games.simulator_instance_id = simulator_instances.id
      ) t
    SQL
  end
end