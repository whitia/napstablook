FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "test#{n}@example.com" }
    password { 'test-test' }
    password_confirmation { 'test-test' }

    trait :email_empty do
      email nil
    end

    trait :password_empty do
      password nil
      password_confirmation nil
    end
  end
end
