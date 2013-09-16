class Profile < ActiveRecord::Base
  validates :assignment, presence: true, format: { with: /\A(\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+; )*\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+\z/ },
                         uniqueness: { scope: :simulator_instance_id }
  validates :size, presence: true, numericality: { only_integer: true }
  validate :profile_matches_simulator

  belongs_to :simulator_instance, inverse_of: :profiles
  validates_presence_of :simulator_instance
  has_many :simulations, inverse_of: :profile, dependent: :destroy
  has_many :scheduling_requirements, dependent: :destroy, inverse_of: :profile
  has_many :symmetry_groups, dependent: :destroy, inverse_of: :profile
  has_many :observations, dependent: :destroy, inverse_of: :profile

  delegate :simulator, to: :simulator_instance
  delegate :simulator_fullname, to: :simulator_instance

  def profile_matches_simulator
    assignment.split("; ").each do |role_string|
      role, strategy_string = role_string.split(": ")
      strategy_string.split(", ").each do |count_strategy|
        strategy = count_strategy.split(" ")[1]
        unless simulator.role_configuration[role].try(:include?, strategy)
          errors.add(:assignment, "#{strategy} is not present in the Simulator")
        end
      end
    end
  end

  before_validation(on: :create) do
    self.size = assignment.role_counts.values.reduce(:+)
    self.role_configuration = {}
    assignment.split("; ").each do |role_string|
      role, strategy_string = role_string.split(": ")
      role_configuration[role] = 0
      strategy_string.split(", ").each do |strategy|
        role_configuration[role] += strategy.split(" ")[0].to_i
      end
    end
  end

  after_create do
    assignment.split("; ").each do |role_string|
      role, strategy_string = role_string.split(": ")
      strategy_string.split(", ").each do |strategy|
        count, strategy = strategy.split(" ")
        self.symmetry_groups.create!(role: role, strategy: strategy, count: count.to_i)
      end
    end
  end

  def try_scheduling
    ProfileScheduler.perform_in(5.minutes, self.id)
  end

  def scheduled?
    simulations.scheduled.count > 0
  end
end
