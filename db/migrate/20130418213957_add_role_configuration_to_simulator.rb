class AddRoleConfigurationToSimulator < ActiveRecord::Migration
  def change
    add_column :simulators, :role_configuration, :hstore
  end
end
