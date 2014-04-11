FactoryGirl.define do
  factory :simulator do
    sequence(:name) { |n| "fake#{n}" }
    sequence(:version) { |n| "#{n}" }
    email 'test@example.com'
    source File.new("#{Rails.root}/spec/support/data/fake_sim.zip")
    configuration { {} }

    trait :with_strategies do
      role_configuration { { 'All' => %w(A B) } }
    end

    trait :with_multi_role_strategies do
      role_configuration { { 'Role1' => %w(A B), 'Role2' => %w(C D) } }
    end

    trait :with_strategies_and_an_empty_role do
      role_configuration { { 'Role1' => [], 'Role2' => %w(A B) } }
    end
  end
end
