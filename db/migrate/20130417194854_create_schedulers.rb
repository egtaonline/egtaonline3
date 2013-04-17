class CreateSchedulers < ActiveRecord::Migration
  def change
    create_table :schedulers do |t|
      t.string :name, :null => false, :unique => true
      t.boolean :active, :null => false, :default => false
      t.integer :process_memory, :null => false
      t.integer :time_per_sample, :null => false
      t.integer :samples_per_simulation, :null => false, :default => 10
      t.integer :nodes, :null => false, :default => 1
      t.integer :size, :null => false
      t.integer :simulator_instance_id, :null => false
      t.hstore :role_configuration
      t.timestamps
    end
  end
end
