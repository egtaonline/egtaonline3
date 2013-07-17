FactoryGirl.define do
  factory :scheduler do
    sequence(:name){ |n| "test#{n}" }
    process_memory 1000
    size 2
    time_per_observation 40
    simulator_instance
    default_observation_requirement 10
    observations_per_simulation 5

    trait :with_profiles do
      simulator_instance { FactoryGirl.create(:simulator_instance, :with_simulator_with_strategies) }
      after(:create) do |instance|
        instance.add_role("All", 2)
        instance.add_strategy("All", "A")
        instance.add_strategy("All", "B")
      end
    end

    trait :with_sampled_profiles do
      simulator_instance { FactoryGirl.create(:simulator_instance, :with_simulator_with_strategies) }
      after(:create) do |instance|
        instance.add_role("All", 2)
        instance.add_strategy("All", "A")
        instance.add_strategy("All", "B")
        instance.reload.scheduling_requirements.each do |sr|
          sr.profile.observations << FactoryGirl.create(:observation, profile_id: sr.profile_id)
        end
      end
    end

    factory :game_scheduler, class: GameScheduler do
    end

    factory :deviation_scheduler, class: DeviationScheduler do
    end

    factory :dpr_deviation_scheduler, class: DprDeviationScheduler do
    end

    factory :dpr_scheduler, class: DprScheduler do
    end

    factory :generic_scheduler, class: GenericScheduler do
      trait :with_profiles do
        simulator_instance { FactoryGirl.create(:simulator_instance, :with_simulator_with_strategies) }
        after(:create) do |instance|
          instance.add_role("All", 2)
          instance.add_profile("All: 2 A")
        end
      end

      trait :with_sampled_profiles do
        simulator_instance { FactoryGirl.create(:simulator_instance, :with_simulator_with_strategies) }
        after(:create) do |instance|
          instance.add_role("All", 2)
          instance.add_strategy("All", "A")
          instance.add_strategy("All", "B")
          instance.add_profile("All: 2 A")
          instance.add_profile("All: 2 B")
          instance.reload.scheduling_requirements.each do |sr|
            sr.profile.observations << FactoryGirl.create(:observation, profile_id: sr.profile_id)
          end
        end
      end
    end

    factory :hierarchical_deviation_scheduler, class: HierarchicalDeviationScheduler do
    end

    factory :hierarchical_scheduler, class: HierarchicalScheduler do
    end
  end
end