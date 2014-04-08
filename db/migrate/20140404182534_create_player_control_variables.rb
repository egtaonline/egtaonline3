class CreatePlayerControlVariables < ActiveRecord::Migration
  def change
    create_table :player_control_variables do |t|
      t.integer :simulator_instance_id, null: false
      t.string :name, null: false
      t.float :coefficient, null: false, default: 0
      t.float :expectation
    end

    change_column :control_variables, :expectation, :float, null: true
    change_column :control_variables, :coefficient, :float, default: 0
  end
end
