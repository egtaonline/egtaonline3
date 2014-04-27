class ControlVariable < ActiveRecord::Base
  belongs_to :simulator_instance, inverse_of: :control_variables

  validates_presence_of :name, :simulator_instance
  validates_uniqueness_of :name, scope: :simulator_instance_id

  has_many :role_coefficients, inverse_of: :control_variable,
                               dependent: :delete_all

  before_create do
    simulator_instance.simulator.role_configuration.keys.each do |role|
      self.role_coefficients.build(role: role)
    end
  end
end
