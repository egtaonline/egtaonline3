class GenericSchedulerPresenter
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
end