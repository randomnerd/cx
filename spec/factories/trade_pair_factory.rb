FactoryGirl.define do
  factory :trade_pair do
    market { create :currency }
    currency { create :currency }
  end
end
