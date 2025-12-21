FactoryBot.define do
  factory :enrollment do
    association :user
    association :batch
    status { :pending }
    request_date { Time.now }

    trait :approved do
      status { :approved }
    end
  end
end
