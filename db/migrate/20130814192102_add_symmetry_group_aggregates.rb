class AddSymmetryGroupAggregates < ActiveRecord::Migration
  self.disable_ddl_transaction!
  def up
    unless Rails.env == 'test'
      execute "WITH aggregates AS (SELECT symmetry_group_id, avg(players.payoff) as payoff, stddev_samp(players.payoff) as payoff_sd from players group by symmetry_group_id)
        UPDATE symmetry_groups SET payoff = aggregates.payoff, payoff_sd = aggregates.payoff_sd FROM aggregates WHERE aggregates.symmetry_group_id = symmetry_groups.id;"
    end
  end

  def down
    unless Rails.env == 'test'
      execute "UPDATE symmetry_groups SET payoff = null, payoff_sd = null;"
    end
  end
end
