FactoryBot.define do
  factory :event do
    billetto_id { SecureRandom.hex(10) }
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraphs(number: 2).join("\n") }
    location { Faker::Address.full_address }
    start_date { 1.week.from_now }
    end_date { 2.weeks.from_now }
    price { Faker::Commerce.price }
    currency { 'USD' }
    organizer { Faker::Company.name }
    image_url { Faker::Internet.url }
    url { Faker::Internet.url }
    fetched_at { Time.current }
  end
end
