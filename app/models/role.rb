class Role < ActiveRecord::Base
  belongs_to :role_owner, :polymorphic => true
  validates_presence_of :role_owner
  validates :count, numericality: { only_integer: true }, presence: true
  validate :count_is_acceptable
  validates :name, presence: true, uniqueness: {
    scope: [:role_owner_id, :role_owner_type] },
    format: { with:  /\A\w+\z/, message: "only letters, numbers, or" +
    " underscores allowed." }

  def count_is_acceptable
    unless unassigned_player_count >= count
      errors.add(:count,
        'can\'t be larger than the owner\'s unassigned player count')
    end
    unless reduced_count <= count
      errors.add(:reduced_count, 'can\'t be larger than count')
    end
  end

  private

  def unassigned_player_count
    roles = role_owner.roles.where.not(id: self.id)
    if roles.count == 0
      role_owner.size
    else
      role_owner.size-roles.collect{ |r| r.count }.reduce(:+)
    end
  end
end
