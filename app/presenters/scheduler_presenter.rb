class SchedulerPresenter
  def initialize(scheduler)
    @scheduler = scheduler
  end

  def to_json(options={})
    case options[:granularity]
    when "with_requirements"
      DB.select_value(with_requirements)
    else
      @scheduler.to_json
    end
  end

  def with_requirements
    sql = <<-SQL
      select row_to_json(t)
      from (
        select schedulers.id, name, type, active, process_memory,
        time_per_observation, observations_per_simulation,
        default_observation_requirement, nodes, size, simulator_id,
        (
          hstore_to_matrix(configuration)
        ) as configuration,
        (
          select array_to_json(array_agg(scheduling_requirement))
          from (
            select profile_id, count as requirement,
            observations_count as current_count
            from profiles, scheduling_requirements
            where profiles.id = scheduling_requirements.profile_id
            and scheduling_requirements.scheduler_id = schedulers.id
          ) scheduling_requirement
        ) as scheduling_requirements
        from schedulers, simulator_instances
        where schedulers.id = #{@scheduler.id}
        and schedulers.simulator_instance_id = simulator_instances.id
      ) t
    SQL
  end
end
