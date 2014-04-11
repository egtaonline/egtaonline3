FactoryGirl.define do
  factory :simulation do
    profile
    state 'pending'
    qos 'cac'
    size 5
    scheduler do
      create(:game_scheduler,
             simulator_instance: profile.simulator_instance)
    end
  end
end
