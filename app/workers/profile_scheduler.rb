class ProfileScheduler
  include Sidekiq::Worker
  sidekiq_options queue: 'high_concurrency'

  def perform(profile_id)
    ActiveRecord::Base.transaction do
      profile = Profile.find(profile_id)
      unless profile.scheduled?
        scheduling_requirement = SchedulingRequirement.joins(:scheduler).where('profile_id = ? AND schedulers.active = ?', profile.id, true).order('count DESC').first
        scheduling_requirement.scheduler.schedule_profile(profile, scheduling_requirement.count) if scheduling_requirement
      end
    end
  end
end