class CreateSimulatorInstances < ActiveRecord::Migration
  def change
    create_table :simulator_instances do |t|
      t.hstore :configuration
      t.timestamps
    end
  end
end
