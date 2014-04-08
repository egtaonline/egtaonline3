class CreateControlVariables < ActiveRecord::Migration
  def change
    create_table :control_variables do |t|
      t.integer :simulator_instance_id, null: false
      t.string :name, null: false
      t.float :coefficient, null: false
      t.float :expectation, null: false
    end
  end
end
