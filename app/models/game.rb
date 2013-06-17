class Game < ActiveRecord::Base
  include ProfileSpaces
  
  attr_accessible :name, :size, :simulator_instance_id

  validates_presence_of :name, :size

  belongs_to :simulator_instance, inverse_of: :games
  has_many :roles, as: :role_owner
  delegate :simulator_fullname, to: :simulator_instance
  delegate :configuration, to: :simulator_instance
  delegate :simulator, to: :simulator_instance

  def profile_space
    return [] if invalid_role_partition?
    AssignmentFormatter.format_assignments(SubgameCreator.subgame_assignments(roles))
  end

  def invalid_role_partition?
    (roles.collect{ |role| role.count }.reduce(:+) != size) | roles.detect{ |r| r.strategies.count == 0 }
  end
  
  def profile_count
    Profile.where("simulator_instance_id = ? AND assignment IN (?) AND observations_count > 0", 
                  simulator_instance_id, profile_space).count
  end
  
  def observation_count
    Observation.joins(:profile).where("profiles.simulator_instance_id = ? AND profiles.assignment IN (?)",
                 simulator_instance_id, profile_space).count
  end
end
