class ProfileAssociator
  include Sidekiq::Worker
  sidekiq_options queue: 'profile_space'

  def perform(scheduler_id)
    ActiveRecord::Base.transaction do
      scheduler = Scheduler.find(scheduler_id)
      profile_space = scheduler.profile_space
      profile_space.each do |assignment|
        ProfileMaker.perform_async(scheduler_id, assignment)
      end
      profile_space = ['EMPTY-SPACE'] if profile_space == []
      ActiveRecord::Base.exec_sql(
        'DELETE FROM scheduling_requirements ' \
        'USING profiles ' \
        'WHERE profile_id = profiles.id ' \
        'AND scheduler_id = ? ' \
        'AND (assignment NOT IN (?) OR simulator_instance_id != ?)',
        scheduler_id, profile_space, scheduler.simulator_instance_id)
    end
  end
end
