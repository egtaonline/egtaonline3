FactoryGirl.define do
  factory :scheduling_requirement do
    profile
    scheduler { FactoryGirl.create(:game_scheduler, simulator_instance: profile.simulator_instance, active: true) }
    count 5
  end
end