FactoryBot.define do
  factory :vote do
    event
    user_id { SecureRandom.uuid }
    vote_type { 'upvote' }
  end

  trait :upvote do
    vote_type { 'upvote' }
  end

  trait :downvote do
    vote_type { 'downvote' }
  end
end
