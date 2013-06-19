class SymmetryGroup < ActiveRecord::Base
  belongs_to :profile, inverse_of: :symmetry_groups

  validates_presence_of :role, :strategy, :count
  validates_numericality_of :count, only_integer: true, greater_than: 0
end
