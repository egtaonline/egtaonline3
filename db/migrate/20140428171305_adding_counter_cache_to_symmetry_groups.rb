class AddingCounterCacheToSymmetryGroups < ActiveRecord::Migration
  def change
    add_column :symmetry_groups, :observation_aggs_count, :integer,
               null: false, default: 0
    execute "WITH agg_counts AS (
               SELECT symmetry_group_id, COUNT(*) as oa_count
               FROM observation_aggs GROUP BY symmetry_group_id
             )
             UPDATE symmetry_groups SET observation_aggs_count = oa_count
             FROM agg_counts
             WHERE agg_counts.symmetry_group_id = symmetry_groups.id"
  end
end
