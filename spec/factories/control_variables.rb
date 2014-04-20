FactoryGirl.define do
  factory :control_variable do
    simulator_instance
    sequence(:name) { |n| "Feature#{n}" }
    expectation 10
  end

  trait :with_role_coefficients do
    after(:create) do |instance|
      assignment = instance.simulator_instance.profiles.first.assignment
      assignment.split('; ').each do |role_strings|
        instance.role_coefficients.create!(
          role: role_strings.split(': ')[0], coefficient: rand)
      end
    end
  end
end
