FactoryGirl.define do
  factory :control_variable do
    simulator_instance
    sequence(:name) { |n| "Feature#{n}" }
    expectation 10
  end

  trait :with_role_coefficients do
    after(:create) do |instance|
      assignment = instance.simulator_instance.profiles.first.assignment
      instance.role_coefficients.each do |r|
        r.update_attributes(coefficient: rand)
      end
    end
  end
end
