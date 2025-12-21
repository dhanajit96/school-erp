FactoryBot.define do
  factory :batch do
    name { "Batch #{Faker::Alphanumeric.alpha(number: 3).upcase}" }
    start_date { Date.today }
    end_date { Date.today + 3.months }
    association :course
  end
end
