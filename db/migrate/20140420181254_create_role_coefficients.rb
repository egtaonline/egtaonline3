class CreateRoleCoefficients < ActiveRecord::Migration
  def change
    create_table :role_coefficients do |t|
      t.integer :control_variable_id, null: false
      t.text :role, null: false
      t.float :coefficient, default: 0.0
      t.index :control_variable_id
    end
    remove_column :control_variables, :coefficient
  end
end
