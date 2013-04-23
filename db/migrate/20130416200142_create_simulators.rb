class CreateSimulators < ActiveRecord::Migration
  def change
    create_table :simulators do |t|
      t.string :name, :null => false, :limit => 32
      t.string :version, :null => false, :limit => 32
      t.string :email, :null => false
      t.string :source, :null => false
      t.hstore :configuration, :null => false
      t.text :role_configuration, :null => false, default: "{}"
      t.timestamps
    end
  end
end
