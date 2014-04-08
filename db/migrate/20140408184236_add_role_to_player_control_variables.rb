class AddRoleToPlayerControlVariables < ActiveRecord::Migration
  def change
    add_column :player_control_variables, :role, :string, null: false
    add_index :control_variables, :simulator_instance_id
    add_index :player_control_variables, [:simulator_instance_id, :role], name: :pcv_sid_role_index
  end
end
