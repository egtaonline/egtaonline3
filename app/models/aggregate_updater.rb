class AggregateUpdater
  def self.update(observations, profile)
    ActiveRecord::Base.transaction do
      profile.lock!
      profile.symmetry_groups.each do |sgroup|
        sgroup.lock!
        observations.each do |observation|
          observation.observation_aggs.create!(symmetry_group_id: sgroup.id)
        end
      end
    end
  end
end
