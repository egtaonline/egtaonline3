class RoleCoefficient < ActiveRecord::Base
  belongs_to :control_variable, inverse_of: :role_coefficients
  validates_presence_of :control_variable, :role
  validates_uniqueness_of :role, scope: :control_variable_id
end
