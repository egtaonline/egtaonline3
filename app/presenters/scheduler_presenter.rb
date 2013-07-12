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
  # def json_specialization
  #   ",\"roles\":[#{@scheduler.roles.collect{ |role| "{\"name\":\"#{role.name}\",\"count\":#{role.count}}" }.join(",") }]," <<
  #   "\"samples_per_simulation\":#{@scheduler.samples_per_simulation},\"nodes\":#{@scheduler.nodes},\"sample_hash\":#{sample_hash.to_json}"
  # end
  #
  # private
  #
  # def sample_hash
  #   shash = {}
  #   Profile.where(:_id.in => @scheduler.sample_hash.keys).only(:sample_count).each do |profile|
  #     local_hash = {}
  #     local_hash["requested_samples"] = @scheduler.sample_hash[profile["_id"].to_s]
  #     local_hash["sample_count"] = profile["sample_count"]
  #     shash[profile["_id"]] = local_hash
  #   end
  #   shash
  # end
