class Observation < ActiveRecord::Base
  belongs_to :profile, inverse_of: :observations, counter_cache: true
  validates_presence_of :profile
  has_many :players, inverse_of: :observation, dependent: :destroy
  has_many :observation_aggs, inverse_of: :observation, dependent: :destroy

  def self.create_from_validated_data(profile, data)
    observation = profile.observations.create(features: data["features"])
    if observation.valid?
      data["symmetry_groups"].each do |symmetry_group|
        sgroup = profile.symmetry_groups.find_by(
          role: symmetry_group["role"], strategy: symmetry_group["strategy"])
        symmetry_group["players"].each do |player|
          Player.create!(observation_id: observation.id, symmetry_group_id: sgroup.id,
            features: player["features"], payoff: player["payoff"])
        end
        observation.observation_aggs.create(symmetry_group_id: sgroup.id)
        payoffs = Player.where(symmetry_group_id: sgroup.id).order("").select("avg(payoff) as payoff, stddev_samp(payoff) as payoff_sd").first
        sgroup.update_attributes(payoff: payoffs["payoff"], payoff_sd: payoffs["payoff_sd"])
      end
      observation
    end
  end
end
