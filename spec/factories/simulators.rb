FactoryGirl.define do
  factory :simulator do
    name 'fake_sim'
    sequence(:version){ |n| "#{n}" }
    email 'test@example.com'
    source File.new("#{Rails.root}/spec/support/data/fake_sim.zip")
  end
end