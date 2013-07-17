class Role < ActiveRecord::Base
  belongs_to :role_owner, :polymorphic => true
  validates :count, numericality: { only_integer: true }, presence: true
  validate :count_is_acceptable
  validates :name, presence: true, uniqueness: {
    scope: [:role_owner_id, :role_owner_type] },
    format: { with:  /\A\w+\z/, message: "only letters, numbers, or" +
    " underscores allowed." }

  def count_is_acceptable
    unless role_owner.unassigned_player_count >= 0
      errors.add(:count,
        'can\'t be larger than the owner\'s unassigned player count')
    end
    unless reduced_count <= count
      errors.add(:reduced_count, 'can\'t be larger than count')
    end
  end
end
