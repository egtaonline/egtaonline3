Simulator.skip_callback(:validation, :before, :setup_simulator)

FactoryGirl.define do
  factory :simulator do
    name 'fake_sim'
    sequence(:version){ |n| "#{n}" }
    email 'test@example.com'
    source File.new("#{Rails.root}/spec/support/data/fake_sim.zip")
    configuration { {} }

    trait :with_setup do
      before(:validation) { |simulator| simulator.send(:setup_simulator) }
    end

    trait :with_strategies do
      role_configuration { { 'All' => ['A', 'B'] } }
    end

    trait :with_multi_role_strategies do
      role_configuration { { 'Role1' => ['A', 'B'], 'Role2' => ['C', 'D'] } }
    end

    trait :with_strategies_and_an_empty_role do
      role_configuration { { "Role1" => [], "Role2" => ['A', 'B'] } }
    end
  end
end