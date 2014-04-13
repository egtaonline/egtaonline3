module ProfileSpaces
  def invalid_role_partition?
    roles.map { |role| role.count }.reduce(:+) != size
  end

  def available_roles
    simulator.role_configuration.keys - roles.map { |r| r.name }
  end

  def available_strategies(role_name)
    role = roles.where(name: role_name).first
    (simulator.role_configuration[role_name] -
      role.strategies - role.deviating_strategies).sort
  end

  def unassigned_player_count
    roles.count == 0 ? size : size - roles.map { |r| r.count }.reduce(:+)
  end

  def add_role(role, count, reduced_count = count)
    unless roles.where(name: role).first
      roles.create(name: role, count: count, reduced_count: reduced_count)
    end
  end

  def remove_role(role)
    roles.where(name: role).destroy_all
  end
end
