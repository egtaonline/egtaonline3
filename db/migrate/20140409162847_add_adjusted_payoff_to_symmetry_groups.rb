class AddAdjustedPayoffToSymmetryGroups < ActiveRecord::Migration
  self.disable_ddl_transaction!
  def change
    add_column :symmetry_groups, :adjusted_payoff, :float
    add_column :symmetry_groups, :adjusted_payoff_sd, :float
    add_column :observation_aggs, :adjusted_payoff, :float
    add_column :observation_aggs, :adjusted_payoff_sd, :float
  end
end
