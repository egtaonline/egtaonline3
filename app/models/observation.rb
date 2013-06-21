class Observation < ActiveRecord::Base
  belongs_to :profile, inverse_of: :observations, counter_cache: true
  has_many :players, inverse_of: :observation, dependent: :destroy
end
