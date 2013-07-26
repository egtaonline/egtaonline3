class Game < ActiveRecord::Base
  include ProfileSpaces

  validates_presence_of :size
  validates :name, presence: true, uniqueness: { scope: :simulator_instance_id }

  belongs_to :simulator_instance, inverse_of: :games
  validates_presence_of :simulator_instance
  has_many :roles, as: :role_owner, dependent: :destroy
  delegate :simulator_fullname, to: :simulator_instance
  delegate :configuration, to: :simulator_instance
  delegate :simulator, to: :simulator_instance

  def profile_space
    roles.order("name ASC").collect{|r| "#{r.name}: \\d+ (#{r.strategies.join('(, \\d+ )?)*(')}(, \\d+ )?)*"}.join("; ")
  end

  def invalid_role_partition?
    super || roles.detect{ |r| r.strategies.count == 0 } != nil
  end

  def profile_count
    Profile.where("simulator_instance_id = ? AND role_configuration @> (?) AND assignment SIMILAR TO (?) AND" +
      " observations_count > 0", simulator_instance_id, role_configuration, profile_space).count
  end

  def observation_count
    Observation.joins(:profile).where("profiles.simulator_instance_id = ? AND profiles.role_configuration @> (?) AND profiles.assignment SIMILAR TO (?)",
                 simulator_instance_id, role_configuration, profile_space).count
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

  def role_configuration
    roles.collect{ |role| "\"#{role.name}\" => #{role.count}" }.join(", ")
  end
end
