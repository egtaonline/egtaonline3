class ProfileAssociator
  include Sidekiq::Worker
  sidekiq_options queue: 'profile_space'

  def perform(scheduler_id)
    scheduler = Scheduler.find(scheduler_id)
    profile_space = scheduler.profile_space
    profile_space.each do |assignment|
      ProfileMaker.perform_async(scheduler_id, assignment)
    end
    profile_space = ["EMPTY-SPACE"] if profile_space == []
    SchedulingRequirement.includes(:profile).where("scheduler_id = ? AND" +
      " (assignment NOT IN (?) OR simulator_instance_id != ?)", scheduler_id,
      profile_space,
      scheduler.simulator_instance_id).references(:profile).destroy_all
  end
end