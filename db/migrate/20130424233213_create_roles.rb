class CreateRoles < ActiveRecord::Migration
  def change
    create_table :roles do |t|
      t.integer :count, :null => false
      t.integer :reduced_count, :null => false
      t.string :name, :null => false
      t.integer :role_owner_id, :null => false
      t.string :role_owner_type, :null => false
      t.string :strategies, array: true, default: []
      t.string :deviating_strategies, array: true, default: []
      t.timestamps
    end
  end
end
