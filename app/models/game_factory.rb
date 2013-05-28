class GameFactory
  def self.create_game_to_match(scheduler)
    game = Game.create!(name: scheduler.name, size: scheduler.size, simulator_instance_id: scheduler.simulator_instance_id)
    scheduler.roles.each do |role|
      game.roles.create!(name: role.name, count: role.count, reduced_count: role.count, strategies: role.strategies+role.deviating_strategies)
    end
    game
  end
end