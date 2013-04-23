class CreateSchedulers < ActiveRecord::Migration
  def change
    create_table :schedulers do |t|
      t.string :name, :null => false, :unique => true
      t.boolean :active, :null => false, :default => false
      t.integer :process_memory, :null => false
      t.integer :time_per_observation, :null => false
      t.integer :observations_per_simulation, :null => false, :default => 10
      t.integer :default_observation_requirement, :null => false, :default => 10
      t.integer :nodes, :null => false, :default => 1
      t.integer :size, :null => false
      t.integer :simulator_instance_id, :null => false
      t.text :role_configuration, :null => false, :default => '{}'
      t.timestamps
    end
  end
end
