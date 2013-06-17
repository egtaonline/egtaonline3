class Profile < ActiveRecord::Base
  attr_accessible :assignment

  validates :assignment, presence: true, format: { with: /\A(\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+; )*\w+:( \d+ [\w:.-]+,)* \d+ [\w:.-]+\z/ },
                         uniqueness: { scope: :simulator_instance_id }
  validates :size, presence: true, numericality: { only_integer: true }

  belongs_to :simulator_instance, inverse_of: :profiles
  has_many :simulations, inverse_of: :profile, dependent: :destroy
  has_many :scheduling_requirements, dependent: :destroy, inverse_of: :profile
  has_many :symmetry_groups, dependent: :destroy, inverse_of: :profile
  has_many :observations, dependent: :destroy, inverse_of: :profile

  before_validation(on: :create) do
    self.size = assignment.split("; ").collect do |role|
      role.split(': ')[1].split(", ").collect do |strategy|
        strategy.split(" ")[0].to_i
      end.reduce(:+)
    end.reduce(:+)
  end

  after_create do
    assignment.split("; ").each do |role|
      rsplit = role.split(": ")
      rsplit[1].split(", ").each do |strategy|
        ssplit = strategy.split(" ")
        self.symmetry_groups.create!(role: rsplit[0], strategy: ssplit[1], count: ssplit[0].to_i)
      end
    end
    try_scheduling
  end

  def try_scheduling
    ProfileScheduler.perform_in(5.minutes, self.id)
  end

  def scheduled?
    simulations.scheduled.count > 0
  end
end