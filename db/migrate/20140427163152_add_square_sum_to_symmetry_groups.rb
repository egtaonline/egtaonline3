class AddSquareSumToSymmetryGroups < ActiveRecord::Migration
  def change
    add_column :symmetry_groups, :sum_sq_diff, :float
    add_column :symmetry_groups, :adj_sum_sq_diff, :float
    execute(
      'WITH aggs AS (
         SELECT symmetry_group_id, regr_sxx(payoff, payoff) as ssd,
                regr_sxx(adjusted_payoff, adjusted_payoff) as assd
         FROM observation_aggs
         GROUP BY symmetry_group_id
       )
       UPDATE symmetry_groups
       SET sum_sq_diff = ssd, adj_sum_sq_diff = assd
       FROM aggs
       WHERE aggs.symmetry_group_id = symmetry_groups.id')
  end
end
