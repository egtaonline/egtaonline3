class AddIndexesEverywhere < ActiveRecord::Migration
  def up
    add_index :simulators, [:name, :version], unique: true
    add_index :simulator_instances, :simulator_id
    execute "CREATE INDEX simulator_instances_gin_configuration ON" +
      " simulator_instances USING GIN(configuration)"
    add_index :scheduling_requirements, :scheduler_id
    add_index :scheduling_requirements, [:profile_id, :scheduler_id],
      unique: true
    add_index :profiles, [:simulator_instance_id, :assignment], unique: true
    add_index :games, [:simulator_instance_id, :name], unique: true
    add_index :symmetry_groups, [:profile_id, :role, :strategy], unique: true
    add_index :observations, :profile_id
    add_index :players, :observation_id
    add_index :players, :symmetry_group_id
    add_index :simulations, :profile_id
    add_index :schedulers, [:simulator_instance_id, :name], unique: true
    add_index :roles, [:role_owner_id, :role_owner_type, :name], unique: true
  end

  def down
    remove_index :simulators, [:name, :version]
    remove_index :simulator_instances, :simulator_id
    execute "DROP INDEX simulator_instances_gin_configuration"
    remove_index :scheduling_requirements, :scheduler_id
    remove_index :scheduling_requirements, [:profile_id, :scheduler_id]
    remove_index :profiles, [:simulator_instance_id, :assignment]
    remove_index :games, [:simulator_instance_id, :name]
    remove_index :symmetry_groups, [:profile_id, :role, :strategy]
    remove_index :observations, :profile_id
    remove_index :players, :observation_id
    remove_index :players, :symmetry_group_id
    remove_index :simulations, :profile_id
    remove_index :schedulers, [:simulator_instance_id, :name]
    remove_index :roles, [:role_owner_id, :role_owner_type, :name]
  end
end
