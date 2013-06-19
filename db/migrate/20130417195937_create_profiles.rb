class CreateProfiles < ActiveRecord::Migration
  def change
    create_table :profiles do |t|
      t.integer :simulator_instance_id, :null => false
      t.integer :size, :null => false
      t.integer :observations_count, :null => false, :default => 0
      t.string :assignment, :null => false
      t.timestamps
    end
  end
end
