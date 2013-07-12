class ProfilePresenter
  def initialize(profile)
    @profile = profile
  end

  def to_json(options={})
    case options[:granularity]
    when "structure"
      @profile.to_json
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
  end

  def observations
  end

  def full
  end
end