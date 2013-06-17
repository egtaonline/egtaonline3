class RemovePayoffAndPayoffSdFromSymmetryGroups < ActiveRecord::Migration
  def change
    remove_column :symmetry_groups, :payoff
    remove_column :symmetry_groups, :payoff_sd
  end
end
