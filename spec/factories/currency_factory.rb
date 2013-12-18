FactoryGirl.define do
  factory :currency do
    name
  end
  sequence :name do |n|
    "name#{n}"
  end
end
