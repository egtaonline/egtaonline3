class AddPreaggregates < ActiveRecord::Migration
  self.disable_ddl_transaction!
  def up
    add_column :symmetry_groups, :payoff, :float
    add_column :symmetry_groups, :payoff_sd, :float
    create_table :observation_aggs do |t|
      t.integer :observation_id, null: false
      t.integer :symmetry_group_id, null: false
      t.float :payoff, null: false
      t.float :payoff_sd
    end

    unless Rails.env == 'test'
      execute 'INSERT INTO observation_aggs(observation_id, symmetry_group_id, payoff, payoff_sd) SELECT observation_id, symmetry_group_id, avg(payoff), stddev_samp(payoff) FROM players GROUP BY observation_id, symmetry_group_id'
    end
    add_index :observation_aggs, [:observation_id, :symmetry_group_id], unique: true
  end

  def down
    remove_index :observation_aggs, [:observation_id, :symmetry_group_id]
    drop_table :observation_aggs
    remove_column :symmetry_groups, :payoff_sd
    remove_column :symmetry_groups, :payoff, :float
  end
end
