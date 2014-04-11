FactoryGirl.define do
  factory :scheduling_requirement do
    profile
    scheduler do
      create(:game_scheduler,
             simulator_instance: profile.simulator_instance, active: true)
    end
    count 5
  end
end
