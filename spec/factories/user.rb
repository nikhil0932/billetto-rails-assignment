FactoryBot.define do
  factory :user do
    clerk_id { SecureRandom.uuid }
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    profile_image_url { Faker::Internet.url }
    last_sign_in_at { Time.current }

    trait :with_votes do
      after(:create) do |user|
        create_list(:vote, 3, user_id: user.clerk_id)
      end
    end

    trait :inactive do
      last_sign_in_at { 60.days.ago }
    end
  end
end
