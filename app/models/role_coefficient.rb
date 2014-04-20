class RoleCoefficient < ActiveRecord::Base
  belongs_to :control_variable, inverse_of: :role_coefficients
  validates_presence_of :control_variable, :role
end
