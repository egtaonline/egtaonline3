class Observation < ActiveRecord::Base
  belongs_to :profile, inverse_of: :observations, counter_cache: true
  validates_presence_of :profile
  has_many :players, inverse_of: :observation, dependent: :destroy
  has_many :observation_aggs, inverse_of: :observation, dependent: :destroy
end
