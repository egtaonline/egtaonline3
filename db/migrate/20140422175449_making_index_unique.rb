class MakingIndexUnique < ActiveRecord::Migration
  def change
    remove_index :control_variate_states, :simulator_instance_id
    add_index :control_variate_states, :simulator_instance_id, unique: true
  end
end
