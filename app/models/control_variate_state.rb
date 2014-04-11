class ControlVariateState < ActiveRecord::Base
  belongs_to :simulator_instance, inverse_of: :control_variate_state
  validates_inclusion_of :state, in: %w(none applying complete)
  validates_presence_of :simulator_instance
end