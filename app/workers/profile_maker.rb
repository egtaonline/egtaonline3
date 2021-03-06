class ProfileMaker
  include Sidekiq::Worker
  sidekiq_options queue: 'profile_space'

  def perform(scheduler_id, assignment)
    ActiveRecord::Base.transaction do
      scheduler = Scheduler.find(scheduler_id)
      si = scheduler.simulator_instance
      profile = si.profiles.find_or_create_by(
        assignment: assignment.assignment_sort)
      if profile.valid?
        requirement = profile.scheduling_requirements.where(
          scheduler_id: scheduler.id).first
        if requirement
          requirement.count = scheduler.default_observation_requirement
          requirement.save!
        else
          profile.scheduling_requirements.create!(
            scheduler_id: scheduler.id,
            count: scheduler.default_observation_requirement)
        end
      end
    end
  end
end
