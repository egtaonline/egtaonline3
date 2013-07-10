class Role < ActiveRecord::Base
  belongs_to :role_owner, :polymorphic => true
  validates :count, numericality: { only_integer: true }, presence: true
  validate :count_is_acceptable

  def count_is_acceptable
    unless role_owner.unassigned_player_count >= 0
      errors.add(:count,
        'can\'t be larger than the owner\'s unassigned player count')
    end
  end
end
