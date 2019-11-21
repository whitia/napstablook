FactoryBot.define do
  factory :ratio do
    category { '国株' }
    value { 25.0 }
    increase { 0 }
    association :user
  end
end
