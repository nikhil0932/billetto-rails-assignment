class Event < ApplicationRecord
  has_many :votes, dependent: :destroy

  validates :billetto_id, presence: true, uniqueness: true
  validates :title, presence: true
  validates :start_date, :end_date, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :currency, inclusion: { in: %w(USD EUR GBP DKK SEK NOK) }, allow_nil: true

  scope :upcoming, -> { where('start_date > ?', Time.current).order(:start_date) }
  scope :past, -> { where('end_date < ?', Time.current).order(end_date: :desc) }
  scope :recent, -> { order(fetched_at: :desc) }

  def upvote_count
    votes.where(vote_type: 'upvote').count
  end

  def downvote_count
    votes.where(vote_type: 'downvote').count
  end

  def vote_score
    upvote_count - downvote_count
  end

  def already_voted_by?(user_id)
    votes.exists?(user_id: user_id)
  end

  def user_vote(user_id)
    votes.find_by(user_id: user_id)&.vote_type
  end
end

