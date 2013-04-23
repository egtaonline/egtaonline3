FactoryGirl.define do
  factory :simulator do
    name 'fake_sim'
    sequence(:version){ |n| "#{n}" }
    email 'test@example.com'
    source File.new("#{Rails.root}/spec/support/data/fake_sim.zip")
    
    factory :simulator_with_strategies do
      role_configuration { { "Role1" => [], "Role2" => ['A', 'B'] } }
    end
  end
end