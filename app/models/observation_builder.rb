class ObservationBuilder
  def initialize(profile)
    @profile = profile
  end

  def add_observation(data)
    ActiveRecord::Base.transaction do
      observation = @profile.observations.create!(features: data['features'], extended_features: data['extended_features'])
      data['symmetry_groups'].each { |symmetry_group| process_symmetry_group(observation, symmetry_group) }
    end
  end

  private

  def process_symmetry_group(observation, data)
    sgroup = @profile.symmetry_groups.find_by(role: data['role'], strategy: data['strategy'])
    data['players'].each { |player| PlayerBuilder.build(observation, sgroup, player) }
    observation.observation_aggs.create!(symmetry_group_id: sgroup.id)
    payoffs = ObservationAgg.where(symmetry_group_id: sgroup.id).order('').select('avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd').first
    sgroup.update_attributes!(payoff: payoffs['payoff'], payoff_sd: payoffs['payoff_sd'])
  end
end