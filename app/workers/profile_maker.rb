class ProfileMaker
  include Sidekiq::Worker

  def perform(scheduler_id, assignment)
    scheduler = Scheduler.find(scheduler_id)
    si = scheduler.simulator_instance
    profile = si.profiles.find_or_create_by(assignment: assignment.assignment_sort)
    scheduling_requirement = profile.scheduling_requirements.where(scheduler_id: scheduler.id).first
    if scheduling_requirement
      scheduling_requirement.count = scheduler.default_observation_requirement
      scheduling_requirement.save!
    else
      profile.scheduling_requirements.create!(scheduler_id: scheduler.id, count: scheduler.default_observation_requirement)
    end
  end
end