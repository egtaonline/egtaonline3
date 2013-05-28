class GamePresenter
  def initialize(game)
    @game = game
  end

  def to_json(options={})
    case options[:granularity]
    when "structure"
      structure
    when "full"
      full
    when "observations"
      observations
    else
      summary
    end
  end

  def full
    sql = <<-SQL
      select row_to_json(t)
      from (
      select games.id, games.name, simulator_instances.simulator_fullname, (
      hstore_to_matrix(configuration)
      ) as configuration
      from games, simulator_instances
      where games.id = #{@game.id} and games.simulator_instance_id = simulator_instances.id
      ) t
    SQL

    DB.select_value(sql)
  end
end