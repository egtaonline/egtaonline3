class GenericScheduler < Scheduler
  def update_scheduling_requirements
    scheduling_requirements.destroy_all
  end

  def add_profile(assignment, observation_count=default_observation_requirement)
    assignment = assignment.assignment_sort
    profile = Profile.find_or_create_by(
      simulator_instance_id: self.simulator_instance_id, assignment: assignment)
    if profile.errors.messages.empty?
      role_counts = {}
      roles.each do |role|
        role_counts[role.name] = role.count
      end
      unless role_counts == assignment.role_counts
        profile.errors.add(:assignment, "cannot be scheduled by this" +
        " Scheduler due to mismatch on role partition")
      else
        SchedulingRequirement.joins(:profile).where(
          "scheduler_id = ? AND profiles.assignment = ?",
          id, assignment).destroy_all
        self.scheduling_requirements.create(profile_id: profile.id,
          count: observation_count)
        profile.try_scheduling
      end
    end
    profile
  end
end