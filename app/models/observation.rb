class Observation < ActiveRecord::Base
  attr_accessible :features
  serialize :features, ActiveRecord::Coders::Hstore

  belongs_to :profile, inverse_of: :observations, counter_cache: true
  has_many :players, inverse_of: :observation
end
