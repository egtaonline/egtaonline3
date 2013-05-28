FactoryGirl.define do
  factory :profile do
    assignment "Role1: 2 Strat1; Role2: 1 Strat2, 1 Strat3"
    size { assignment.split("; ").collect{ |role| role.split(": ")[1].split(", ").collect{ |strategy| strategy.split(" ")[0].to_i }.reduce(:+) }.reduce(:+) }
    simulator_instance
  end

  trait :with_observations do
    after(:create) do |instance|
      instance.observations << FactoryGirl.create(:observation, profile_id: instance.id)
    end
  end
end