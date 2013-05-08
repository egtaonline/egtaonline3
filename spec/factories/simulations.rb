FactoryGirl.define do
  factory :simulation do
    profile
    state 'pending'
    qos 'flux'
    size 5
    scheduler { FactoryGirl.create(:game_scheduler, simulator_instance: profile.simulator_instance) }
  end
end