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
  end
end