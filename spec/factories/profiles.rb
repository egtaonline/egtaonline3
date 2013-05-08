FactoryGirl.define do
  factory :profile do
    assignment "Role1: 2 Strat1; Role2: 1 Strat2, 1 Strat3"
    size 4
    simulator_instance
  end
end