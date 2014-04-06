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
      ObservationBuilder.new(instance).add_observation("features" => {},
      "symmetry_groups" => instance.symmetry_groups.collect { |s|
        { "role" => s.role, "strategy" => s.strategy, "players" => Array.new(s.count){ { "features" => {}, "payoff" => 100 } } }
      })
      instance.reload
    end
  end
end