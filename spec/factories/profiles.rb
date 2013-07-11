FactoryGirl.define do
  factory :profile do
    assignment "Role1: 2 Strat1; Role2: 1 Strat2, 1 Strat3"
    simulator_instance
    before(:create) do |instance|
      instance.assignment.split("; ").each do |role_string|
        role, strategy_string = role_string.split(": ")
        strategy_string.split(", ").each do |count_strategy|
          instance.simulator.add_strategy(role, count_strategy.split(" ")[1])
        end
      end
    end
  end

  trait :with_observations do
    after(:create) do |instance|
      instance.observations << FactoryGirl.create(:observation, profile_id: instance.id)
      instance.save!
      instance.reload
    end
  end
end