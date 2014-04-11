module ProfileSpaces
  def invalid_role_partition?
    roles.collect { |role| role.count }.reduce(:+) != size
  end

  def available_roles
    simulator.role_configuration.keys - roles.collect { |r| r.name }
  end

  def available_strategies(role_name)
    role = roles.where(name: role_name).first
    (simulator.role_configuration[role_name] - role.strategies - role.deviating_strategies).sort
  end

  def unassigned_player_count
    roles.count == 0 ? size : size-roles.collect { |r| r.count }.reduce(:+)
  end

  def add_role(role, count, reduced_count=count)
    if !self.roles.where(name: role).first
      self.roles.create(name: role, count: count, reduced_count: reduced_count)
    end
  end

  def remove_role(role)
    self.roles.where(name: role).destroy_all
  end
end