FactoryBot.define do
  factory :fund do
    name { 'ニッセイ−＜購入・換金手数料なし＞ニッセイＴＯＰＩＸインデックスファンド' }
    category { '国株' }
    account { '特定/一般' }
    purchase { 380000 }
    valuation { 413710 }
    difference { 33710 }
    association :user
  end
end
