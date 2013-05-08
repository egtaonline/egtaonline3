FactoryGirl.define do
  factory :scheduler do
    sequence(:name){ |n| "test#{n}" }
    process_memory 1000
    size 2
    time_per_observation 40
    simulator_instance
    default_observation_requirement 10
    observations_per_simulation 5
    
    factory :game_scheduler, class: GameScheduler do
    end
    
    factory :deviation_scheduler, class: DeviationScheduler do
    end
    
    factory :dpr_deviation_scheduler, class: DprDeviationScheduler do
    end
    
    factory :dpr_scheduler, class: DprScheduler do
    end
    
    factory :generic_scheduler, class: GenericScheduler do
    end
    
    factory :hierarchical_deviation_scheduler, class: HierarchicalDeviationScheduler do
    end
    
    factory :hierarchical_scheduler, class: HierarchicalScheduler do
    end
  end
end