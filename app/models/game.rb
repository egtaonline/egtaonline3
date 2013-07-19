class Game < ActiveRecord::Base
  include ProfileSpaces

  validates_presence_of :size
  validates :name, presence: true, uniqueness: { scope: :simulator_instance }

  belongs_to :simulator_instance, inverse_of: :games
  validates_presence_of :simulator_instance
  has_many :roles, as: :role_owner
  delegate :simulator_fullname, to: :simulator_instance
  delegate :configuration, to: :simulator_instance
  delegate :simulator, to: :simulator_instance

  def profile_space
    return [] if invalid_role_partition?
    AssignmentFormatter.format_assignments(
      SubgameCreator.subgame_assignments(roles))
  end

  def invalid_role_partition?
    super || roles.detect{ |r| r.strategies.count == 0 } != nil
  end

  def profile_count
    Profile.where("simulator_instance_id = ? AND assignment IN (?) AND" +
      " observations_count > 0", simulator_instance_id, profile_space).count
  end

  def observation_count
    Observation.joins(:profile).where("profiles.simulator_instance_id = ? AND profiles.assignment IN (?)",
                 simulator_instance_id, profile_space).count
  end

  def add_strategy(role_name, strategy)
    role = self.roles.where(name: role_name).first
    if role
      role.strategies += [strategy]
      role.strategies.uniq!
      role.save!
    end
  end

  def remove_strategy(role_name, strategy)
    role = self.roles.where(name: role_name).first
    if role && role.strategies.include?(strategy)
      role.strategies -= [strategy]
      role.save!
    end
  end
end
