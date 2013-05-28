FactoryGirl.define do
  factory :observation do
    profile
    features { {} }
    before(:create) do |observation|
      observation.profile.symmetry_groups.each do |symmetry_group|
        symmetry_group.count.times do
          observation.players.build(symmetry_group_id: symmetry_group.id, features: {}, payoff: 100)
        end
      end
    end
  end
end