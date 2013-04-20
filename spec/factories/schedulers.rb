FactoryGirl.define do
  factory :game_scheduler do
    sequence(:name){ |n| "test#{n}" }
    process_memory 1000
    size 2
    time_per_observation 40
    simulator_instance
  end
end