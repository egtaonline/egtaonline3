class GameFactory
  def self.create(params, simulator_id, configuration)
    params[:simulator_instance_id] = get_simulator_instance_id(simulator_id, configuration) if params
    Game.create(params)
  end

  def self.create_game_to_match(scheduler)
    game = Game.create!(name: scheduler.name, size: scheduler.size, simulator_instance_id: scheduler.simulator_instance_id)
    scheduler.roles.each do |role|
      game.roles.create!(name: role.name, count: role.count, reduced_count: role.count, strategies: role.strategies+role.deviating_strategies)
    end
    game
  end

  private

  # If find_or_create_by works, use that instead
  def self.get_simulator_instance_id(simulator_id, configuration)
    configuration ||= {}
    simulator_instance = SimulatorInstance.where("simulator_id = ? AND configuration @> (?)", simulator_id, configuration.collect{ |key, value| "#{key} => #{value}" }.join(", ")).first
    simulator_instance ||= SimulatorInstance.create!(simulator_id: simulator_id, configuration: configuration)
    simulator_instance.id
  end
end