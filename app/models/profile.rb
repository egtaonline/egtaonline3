class Profile < ActiveRecord::Base
  attr_accessible :assignment

  validates :assignment, presence: true, format: { with: /\A(\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+; )*\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+\z/ },
                         uniqueness: { scope: :simulator_instance_id }
  validates :size, presence: true, numericality: { only_integer: true }

  has_and_belongs_to_many :games
  belongs_to :simulator_instance, inverse_of: :profiles
  has_many :simulations, inverse_of: :profile, dependent: :destroy
  has_many :scheduling_requirements, inverse_of: :profile
  has_many :symmetry_groups, inverse_of: :profile
  has_many :observations, inverse_of: :profile
end
