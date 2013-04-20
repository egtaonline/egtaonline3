class CreateSimulatorInstances < ActiveRecord::Migration
  def change
    create_table :simulator_instances do |t|
      t.hstore :configuration
      t.integer :simulator_id, :null => false
      t.timestamps
    end
  end
end
