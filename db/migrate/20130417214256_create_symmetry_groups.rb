class CreateSymmetryGroups < ActiveRecord::Migration
  def change
    create_table :symmetry_groups do |t|
      t.integer :profile_id, :null => false
      t.string :role, :null => false
      t.string :strategy, :null => false
      t.integer :count, :null => false
      t.float :payoff
      t.float :payoff_sd

      t.timestamps
    end
  end
end
