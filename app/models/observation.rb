class Observation < ActiveRecord::Base
  belongs_to :profile, inverse_of: :observations, counter_cache: true
  validates_presence_of :profile
  has_many :players, inverse_of: :observation, dependent: :destroy
  has_many :observation_aggs, inverse_of: :observation, dependent: :destroy

  def self.create_from_validated_data(profile, data)
    observation = profile.observations.create(features: data["features"])
    if observation.valid?
      data["symmetry_groups"].each do |symmetry_group|
        symmetry_group_id = profile.symmetry_groups.find_by(
          role: symmetry_group["role"], strategy: symmetry_group["strategy"]).id
        symmetry_group["players"].each do |player|
          observation.players.create(symmetry_group_id: symmetry_group_id,
            features: player["features"], payoff: player["payoff"])
        end
        observation.observation_aggs.create(symmetry_group_id: symmetry_group_id)
        DB.execute "
          WITH aggregates AS (SELECT symmetry_group_id, avg(players.payoff) as payoff, stddev_samp(players.payoff) as payoff_sd from players where symmetry_group_id=#{symmetry_group_id} group by symmetry_group_id)
          UPDATE symmetry_groups SET payoff = aggregates.payoff, payoff_sd = aggregates.payoff_sd from aggregates WHERE id = aggregates.symmetry_group_id;"
      end
      observation
    end
  end
end
