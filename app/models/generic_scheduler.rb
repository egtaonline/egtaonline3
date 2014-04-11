class GenericScheduler < Scheduler
  def update_scheduling_requirements
    scheduling_requirements.destroy_all
  end

  def add_profile(assignment, observation_count = default_observation_requirement)
    assignment = assignment.assignment_sort
    profile = Profile.find_or_create_by(simulator_instance_id: simulator_instance_id, assignment: assignment)
    if profile.errors.messages.empty?
      if role_valid?(assignment)
        add_strategies(assignment)
        SchedulingRequirement.joins(:profile).where('scheduler_id = ? AND profiles.assignment = ?', id, assignment).destroy_all
        scheduling_requirements.create(profile_id: profile.id, count: observation_count)
      else
        profile.errors.add(:assignment, 'cannot be scheduled by this Scheduler due to mismatch on role partition')
      end
    end
    profile
  end

  def remove_profile_by_id(profile_id)
    scheduling_requirements.where(profile_id: profile_id).destroy_all
    roles.each do |role|
      role.strategies = SymmetryGroup.where(profile_id: scheduling_requirements.pluck(:profile_id), role: role.name).select(:strategy).distinct.pluck(:strategy)
      role.save!
    end
  end

  private

  def role_valid?(assignment)
    role_counts = {}
    roles.each do |role|
      role_counts[role.name] = role.count
    end
    role_counts == assignment.role_counts
  end

  def add_strategies(assignment)
    assignment.split('; ').each do |role_string|
      role, strategy_string = role_string.split(': ')
      grole = roles.find_by(name: role)
      strategies = strategy_string.split(', ').collect { |s| s.split(' ')[1] }
      grole.strategies += strategies
      grole.strategies.uniq!
      grole.save!
    end
  end

  private

  def update_conditions?
    simulator_instance_id_changed? || size_changed?
  end
end
