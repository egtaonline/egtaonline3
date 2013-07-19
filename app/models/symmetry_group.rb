class SymmetryGroup < ActiveRecord::Base
  belongs_to :profile, inverse_of: :symmetry_groups
  has_many :players, inverse_of: :symmetry_group

  validates_presence_of :role, :strategy, :count, :profile
  validates_numericality_of :count, only_integer: true, greater_than: 0

  def payoff
    players.average(:payoff)
  end

  def payoff_sd
    players.reorder('').select(
      'stddev_samp(payoff) as payoff_sd').first['payoff_sd']
  end
end
