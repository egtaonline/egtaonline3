class CreateSchedulingRequirements < ActiveRecord::Migration
  def change
    create_table :scheduling_requirements do |t|
      t.integer :count, :null => false
      t.integer :scheduler_id, :null => false
      t.integer :profile_id, :null => false
      t.timestamps
    end
  end
end
