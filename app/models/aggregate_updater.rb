# AggregateManager controls the construction of new ObservationAggs

class AggregateManager

  # Creates the necessary ObservationAggs
  def self.create_aggregates(observations, profile)

    # Aggressive locking is required because aggregate calculations for a
    # profile must not be interwoven
    ActiveRecord::Base.transaction do
      profile.lock!
      profile.symmetry_groups.each do |sgroup|
        sgroup.lock!
        observations.each do |observation|
          ObservationAgg.create!(observation_id: observation.id,
                                 symmetry_group_id: sgroup.id)
        end
      end
    end
  end
end
