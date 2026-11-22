class User < ApplicationRecord
  # Associations
  has_many :votes, foreign_key: 'user_id', primary_key: 'clerk_id', dependent: :destroy
  has_many :voted_events, through: :votes, source: :event

  # Validations
  validates :clerk_id, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  # Store Clerk user data
  attribute :clerk_id, :string
  attribute :email, :string
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :profile_image_url, :string

  # Scopes
  scope :active, -> { where("updated_at > ?", 30.days.ago) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def has_voted?(event)
    votes.exists?(event: event)
  end

  def vote_type_for(event)
    votes.find_by(event: event)&.vote_type
  end

  def to_s
    full_name.presence || email
  end

  class << self
    def find_or_create_from_clerk(clerk_user)
      find_or_create_by(clerk_id: clerk_user['id']) do |user|
        user.email = clerk_user['email_addresses']&.first&.dig('email_address') || "user_#{clerk_user['id']}@clerk.local"
        user.first_name = clerk_user['first_name']
        user.last_name = clerk_user['last_name']
        user.profile_image_url = clerk_user['profile_image_url']
      end
    rescue ActiveRecord::RecordNotUnique
      find_by(clerk_id: clerk_user['id'])
    end

    def update_from_clerk(clerk_user)
      user = find_or_create_from_clerk(clerk_user)
      user.update(
        email: clerk_user['email_addresses']&.first&.dig('email_address') || user.email,
        first_name: clerk_user['first_name'],
        last_name: clerk_user['last_name'],
        profile_image_url: clerk_user['profile_image_url']
      )
      user
    end
  end
end

