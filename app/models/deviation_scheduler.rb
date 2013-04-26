class DeviationScheduler < Scheduler
  def add_deviating_strategy(role_name, strategy)
    role = self.roles.where(name: role_name).first
    if role
      role.deviating_strategies += [strategy]
      role.save!
      ProfileAssociator.new.associate(self)
    end
  end
  
  def remove_deviating_strategy(role_name, strategy)
    role = self.roles.where(name: role_name).first
    if role && role.deviating_strategies.include?(strategy)
      role.deviating_strategies -= [strategy]
      role.save!
      ProfileAssociator.new.associate(self)
    end
  end
  
  def profile_space
    return [] if invalid_role_partition?
    subgame_assignments = SubgameCreator.subgame_assignments(roles)
    deviation_assignments = DeviationCreator.deviation_assignments(roles)
    AssignmentFormatter.format_assignments((subgame_assignments+deviation_assignments).uniq)
  end
end