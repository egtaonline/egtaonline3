FactoryGirl.define do
  factory :simulator_instance do
    configuration { { 'parm1' => 10, 'parm2' => 'Yes' } }
    simulator
  end
end