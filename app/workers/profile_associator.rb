class ProfileAssociator
  include Sidekiq::Worker

  def perform(scheduler_id)
    scheduler = Scheduler.find(scheduler_id)
    profile_space = scheduler.profile_space
    profile_space.each do |assignment|
      ProfileMaker.perform_async(scheduler_id, assignment)
    end
    # Hack to deal with stupid empty array issues in SQL translation
    profile_space = ["EMPTY-ASSIGNMENT"] if profile_space == []
    SchedulingRequirement.joins(:profile).where("scheduler_id = ? AND (profiles.assignment NOT IN (?) OR profiles.simulator_instance_id != ?)",
                                                scheduler_id, profile_space, scheduler.simulator_instance_id).destroy_all
  end
end