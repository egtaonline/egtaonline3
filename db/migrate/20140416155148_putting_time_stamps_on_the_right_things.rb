class PuttingTimeStampsOnTheRightThings < ActiveRecord::Migration
  def change
    add_timestamps :control_variate_states
    add_timestamps :control_variables
    add_timestamps :player_control_variables
    remove_column :observations, :updated_at
    remove_column :players, :updated_at
    remove_column :scheduling_requirements, :updated_at
    remove_column :simulator_instances, :updated_at
  end
end
