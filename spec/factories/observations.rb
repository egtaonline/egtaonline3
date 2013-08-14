# FactoryGirl.define do
#   factory :observation do
#     profile
#     features { {} }
#     before(:create) do |observation|
#       observation.profile.symmetry_groups.each do |symmetry_group|
#         symmetry_group.count.times do
#           observation.players.build(symmetry_group_id: symmetry_group.id, features: {}, payoff: 100)
#         end
#       end
#     end
#     after(:create) do |observation|
#       observation.profile.symmetry_groups.each do |symmetry_group|
#         DB.execute "
#           WITH aggregates AS (SELECT symmetry_group_id, avg(players.payoff) as payoff, stddev_samp(players.payoff) as payoff_sd from players where symmetry_group_id=#{symmetry_group.id} group by symmetry_group_id)
#           UPDATE symmetry_groups SET payoff = aggregates.payoff, payoff_sd = aggregates.payoff_sd from aggregates WHERE id = aggregates.symmetry_group_id;"
#       end
#       DB.execute "
#       INSERT into observation_aggs(observation_id, symmetry_group_id, payoff, payoff_sd) SELECT observation_id, symmetry_group_id, avg(players.payoff) as payoff, stddev_samp(players.payoff) as payoff_sd
#       FROM players where observation_id = #{observation.id} group by observation_id, symmetry_group_id"
#     end
#   end
# end