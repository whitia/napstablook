FactoryBot.define do
  factory :user do
    email { 'test@example.com' }
    password { 'test-test' }
    password_confirmation { 'test-test' }
  end
end
