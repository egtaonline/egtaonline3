FactoryGirl.define do
  factory :scheduler do
    sequence(:name){ |n| "test#{n}" }
    process_memory 1000
    size 2
    time_per_observation 40
    simulator_instance
    
    factory :game_scheduler do
      type 'GameScheduler'
    end
    
    factory :deviation_scheduler do
      type 'DeviationScheduler'
    end
    
    factory :dpr_deviation_scheduler do
      type 'DprDeviationScheduler'
    end
    
    factory :dpr_scheduler do
      type 'DprScheduler'
    end
    
    factory :generic_scheduler do
      type 'GenericScheduler'
    end
    
    factory :hierarchical_deviation_scheduler do
      type 'HierarchicalDeviationScheduler'
    end
    
    factory :hierarchical_scheduler do
      type 'HierarchicalScheduler'
    end
  end
end