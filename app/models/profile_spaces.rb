module ProfileSpaces
  def available_roles
    simulator.role_configuration.keys - roles.collect{ |r| r.name }
  end

  def available_strategies(role_name)
    simulator.role_configuration[role_name] - roles.where(name: role_name).first.strategies
  end

  def unassigned_player_count
    roles.count == 0 ? size : size-roles.collect{ |r| r.count }.reduce(:+)
  end

  def add_role(role, count, reduced_count=count)
    if !self.roles.where(name: role).first
      self.roles.create!(name: role, count: count, reduced_count: reduced_count)
    end
  end

  def remove_role(role)
    self.roles.where(name: role).destroy_all
  end

  def add_strategy(role_name, strategy)
    role = self.roles.where(name: role_name).first
    if role
      role.strategies += [strategy]
      role.strategies.uniq!
      role.save!
    end
  end

  def remove_strategy(role_name, strategy)
    role = self.roles.where(name: role_name).first
    if role && role.strategies.include?(strategy)
      role.strategies -= [strategy]
      role.save!
    end
  end
end