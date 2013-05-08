class ProfileAssociator
  include Sidekiq::Worker
  
  def perform(scheduler_id)
    scheduler = Scheduler.find(scheduler_id)
    profile_space = scheduler.profile_space
    profile_space.each do |assignment|
      ProfileMaker.perform_async(scheduler_id, assignment)
    end
    SchedulingRequirement.joins(:profile).where("scheduler_id = ? AND profiles.assignment NOT IN (?)",
                                                scheduler_id, profile_space).destroy_all
  end
end