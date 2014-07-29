class Game < ActiveRecord::Base
  include ProfileSpaces
  attr_accessor :time
  validates_presence_of :size
  validates :name, presence: true,
                   uniqueness: { scope: :simulator_instance_id }

  belongs_to :simulator_instance, inverse_of: :games
  validates_presence_of :simulator_instance
  has_many :roles, as: :role_owner, dependent: :destroy
  delegate :simulator_fullname, to: :simulator_instance
  delegate :configuration, to: :simulator_instance
  delegate :simulator, to: :simulator_instance
  delegate :control_variate_state, to: :simulator_instance

  def profile_space
    '(' +
      roles.map { |r| "(role = '#{r.name}' AND #{r.strategy_query})" }
      .join(' OR ') + ')'
  end

  def invalid_role_partition?
    super || roles.find { |r| r.strategies.count == 0 }
  end

  def profile_counts
    if invalid_role_partition?
      { 'count' => 0, 'observations_count' => 0 }
    else
      Game.connection.select_all("WITH reasonable_profiles AS (
          SELECT symmetry_groups.id, symmetry_groups.profile_id,
            symmetry_groups.role, symmetry_groups.strategy,
            profiles.observations_count
          FROM symmetry_groups, profiles
          WHERE symmetry_groups.profile_id = profiles.id
          AND profiles.simulator_instance_id = #{simulator_instance_id}
          AND profiles.role_configuration @> #{role_configuration}
          AND profiles.observations_count > 0),
          out_space AS (
            SELECT * FROM reasonable_profiles WHERE NOT #{profile_space}),
          result AS (SELECT DISTINCT ON(profile_id) observations_count
            FROM reasonable_profiles
            WHERE profile_id NOT IN (
              SELECT DISTINCT ON(profile_id) profile_id FROM out_space))
        SELECT COUNT(*) AS count, SUM(observations_count) AS observations_count
        FROM result
      ")[0]
    end
  end

  def observation_count
    Profile.where(
      'profiles.simulator_instance_id = ?
      AND profiles.role_configuration @> (?)
      AND profiles.assignment SIMILAR TO (?) AND observations_count > 0',
      simulator_instance_id, role_configuration, profile_space)
      .sum(:observations_count)
  end

  def add_strategy(role_name, strategy)
    role = roles.where(name: role_name).first
    if role
      role.strategies += [strategy]
      role.strategies.uniq!
      role.strategies.sort!
      role.save!
    end
  end

  def remove_strategy(role_name, strategy)
    role = roles.where(name: role_name).first
    if role && role.strategies.include?(strategy)
      role.strategies -= [strategy]
      role.save!
    end
  end

  def role_configuration
    "('" +
      roles.map { |role| "\"#{role.name}\" => #{role.count}" }
      .join(', ') + "')"
  end
end
