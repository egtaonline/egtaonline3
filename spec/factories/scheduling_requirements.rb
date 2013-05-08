FactoryGirl.define do
  factory :scheduling_requirement do
    profile
    scheduler { FactoryGirl.create(:game_scheduler, simulator_instance: profile.simulator_instance) }
    count 5
  end
end