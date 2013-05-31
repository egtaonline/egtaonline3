FactoryGirl.define do
  factory :game do
    sequence(:name){ |n| "Game#{n}" }
    size 2
    simulator_instance

    trait :with_strategies do
      size 5
      simulator_instance { FactoryGirl.create(:simulator_instance, :with_simulator_with_multi_role_strategies) }
      after(:create) do |instance|
        instance.roles.create(name: 'Role1', count: 3, reduced_count: 3, strategies: ['A', 'B'])
        instance.roles.create(name: 'Role2', count: 2, reduced_count: 2, strategies: ['C', 'D'])
      end
    end

    trait :complicated_test_scenario do
      simulator_instance { FactoryGirl.create(:simulator_instance, :with_simulator_with_strategies) }
      size 60
      after(:create) do |instance|
        instance.simulator_instance.simulator.add_strategy('All', 'C')
        instance.simulator_instance.simulator.add_strategy('All', 'D')
        instance.roles.create(name: 'All', count: 60, reduced_count: 60, strategies: ['A', 'B', 'C'])
        scheduler = FactoryGirl.create(:game_scheduler, size: 60, simulator_instance_id: instance.simulator_instance_id)
        scheduler.add_role('All', 60)
        scheduler.add_strategy('All', 'A')
        scheduler.add_strategy('All', 'B')
        scheduler.add_strategy('All', 'C')
        scheduler.add_strategy('All', 'D')
      end
    end
  end
end