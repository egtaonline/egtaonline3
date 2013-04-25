class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.string :name, :null => false
      t.integer :size, :null => false
      t.integer :simulator_instance_id, :null => false
      t.timestamps
    end
  end
end
