FactoryBot.define do
  factory :school do
    name { Faker::Educator.university }
    address { Faker::Address.full_address }
    subdomain { Faker::Internet.domain_word }
  end
end
