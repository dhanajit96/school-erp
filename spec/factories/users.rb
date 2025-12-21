FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { 'password123' }

    # Add this line to ensure JTI is never nil
    jti { SecureRandom.uuid }

    # Default is a student with a school
    role { :student }
    association :school

    trait :admin do
      role { :admin }
      school { nil }
    end

    trait :school_admin do
      role { :school_admin }
      association :school
    end

    trait :student do
      role { :student }
      association :school
    end
  end
end
