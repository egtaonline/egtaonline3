FactoryGirl.define do
  factory :simulator_instance do
    configuration { { 'parm1' => 10, 'parm2' => 'Yes' } }
    simulator
  end

  trait :with_simulator_with_strategies do
    simulator { create(:simulator, :with_strategies) }
  end

  trait :with_simulator_with_multi_role_strategies do
    simulator { create(:simulator, :with_multi_role_strategies) }
  end
end