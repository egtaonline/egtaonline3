module PatternBasedScheduler
  def add_strategy(role_name, strategy)
    role = roles.where(name: role_name).first
    if role
      role.strategies += [strategy]
      role.strategies.uniq!
      role.strategies.sort!
      role.save!
      update_requirements
      if role.deviating_strategies.include? strategy
        self.remove_deviating_strategy(role_name, strategy)
      end
    end
  end

  def remove_strategy(role_name, strategy)
    role = roles.where(name: role_name).first
    if role && role.strategies.include?(strategy)
      role.strategies -= [strategy]
      role.save!
      update_requirements
    end
  end

  def invalid_role_partition?
    super || roles.find { |r| r.strategies.count == 0 }
  end
end
