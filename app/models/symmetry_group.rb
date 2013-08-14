class SymmetryGroup < ActiveRecord::Base
  belongs_to :profile, inverse_of: :symmetry_groups
  has_many :players, inverse_of: :symmetry_group
  has_many :observation_aggs, inverse_of: :symmetry_group, dependent: :destroy

  validates_presence_of :role, :strategy, :count, :profile
  validates_numericality_of :count, only_integer: true, greater_than: 0
end
