module ProfileSpaces
  def available_strategies(role_name)
    simulator.role_configuration[role_name] - self.roles.where(name: role_name).first.strategies
  end
  
  def unassigned_player_count
    roles.count == 0 ? size : size-roles.collect{ |r| r.count }.reduce(:+)
  end
end