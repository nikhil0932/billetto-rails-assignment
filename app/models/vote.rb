class Vote < ApplicationRecord
  belongs_to :event

  validates :event_id, :user_id, :vote_type, presence: true
  validates :vote_type, inclusion: { in: %w(upvote downvote) }
  validates :user_id, uniqueness: { scope: [:event_id, :vote_type] }

  enum :vote_type, { upvote: 'upvote', downvote: 'downvote' }

  scope :upvotes, -> { where(vote_type: 'upvote') }
  scope :downvotes, -> { where(vote_type: 'downvote') }
end
