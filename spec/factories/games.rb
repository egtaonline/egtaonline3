FactoryGirl.define do
  factory :game do
    sequence(:name){ |n| "Game#{n}" }
    size 2
    simulator_instance

    trait :with_strategies do
      simulator_instance { FactoryGirl.create(:simulator_instance, :with_simulator_with_strategies) }
      after(:create) do |instance|
        instance.roles.create(name: 'All', count: 2, reduced_count: 2, strategies: ['A', 'B'])
      end
    end
  end
end