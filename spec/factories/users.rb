FactoryGirl.define do
  factory :user do
    email                 'test@example.com'
    password              'fake-password'
    password_confirmation 'fake-password'

    factory :approved_user do
      approved true

      factory :admin do
        admin true
      end
    end
  end
end