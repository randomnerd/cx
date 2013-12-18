FactoryGirl.define do
  factory :user do
    sequence :email do |n|
      "user-#{n}@exapmle.com"
    end
    password { SecureRandom.hex(16) }
  end
end
