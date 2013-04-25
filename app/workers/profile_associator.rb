class ProfileAssociator
  def associate(scheduler)
    profile_space = scheduler.profile_space
    profile_space.each do |assignment|
      ProfileMaker.new.find_or_create(scheduler, assignment)
    end
    SchedulingRequirement.joins(:profile).where("scheduler_id = ? AND profiles.assignment NOT IN (?)",
                                                scheduler.id, profile_space).destroy_all
  end
end