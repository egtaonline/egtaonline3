class PlayerControlVariable < ActiveRecord::Base
  belongs_to :simulator_instance, inverse_of: :player_control_variables

  validates_presence_of :name, :simulator_instance
  validates_uniqueness_of :name, scope: [:simulator_instance_id, :role]
end