require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:votes) }
    it { is_expected.to have_many(:voted_events).through(:votes) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:clerk_id) }
    it { is_expected.to validate_presence_of(:email) }

    it 'validates uniqueness of clerk_id' do
      user1 = create(:user, clerk_id: 'clerk_123')
      user2 = build(:user, clerk_id: 'clerk_123')
      expect(user2).not_to be_valid
    end

    it 'validates uniqueness of email' do
      user1 = create(:user, email: 'test@example.com')
      user2 = build(:user, email: 'test@example.com')
      expect(user2).not_to be_valid
    end
  end

  describe '#full_name' do
    it 'returns full name when both names are present' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end

    it 'returns empty string when both names are blank' do
      user = build(:user, first_name: nil, last_name: nil)
      expect(user.full_name).to eq('')
    end

    it 'returns only first name when last name is blank' do
      user = build(:user, first_name: 'John', last_name: nil)
      expect(user.full_name).to eq('John')
    end
  end

  describe '#has_voted?' do
    let(:user) { create(:user) }
    let(:event) { create(:event) }

    it 'returns true if user has voted on event' do
      create(:vote, event: event, user_id: user.clerk_id)
      expect(user.has_voted?(event)).to be true
    end

    it 'returns false if user has not voted on event' do
      expect(user.has_voted?(event)).to be false
    end
  end

  describe '#vote_type_for' do
    let(:user) { create(:user) }
    let(:event) { create(:event) }

    it 'returns vote type if user has voted' do
      vote = create(:vote, event: event, user_id: user.clerk_id, vote_type: 'upvote')
      expect(user.vote_type_for(event)).to eq('upvote')
    end

    it 'returns nil if user has not voted' do
      expect(user.vote_type_for(event)).to be_nil
    end
  end

  describe '#to_s' do
    it 'returns full name when available' do
      user = build(:user, first_name: 'John', last_name: 'Doe', email: 'john@example.com')
      expect(user.to_s).to eq('John Doe')
    end

    it 'returns email when full name is unavailable' do
      user = build(:user, first_name: nil, last_name: nil, email: 'john@example.com')
      expect(user.to_s).to eq('john@example.com')
    end
  end

  describe '.find_or_create_from_clerk' do
    let(:clerk_user) do
      {
        'id' => 'user_123',
        'email_addresses' => [{ 'email_address' => 'john@example.com' }],
        'first_name' => 'John',
        'last_name' => 'Doe',
        'profile_image_url' => 'https://example.com/image.jpg'
      }
    end

    it 'creates a new user from clerk data' do
      user = User.find_or_create_from_clerk(clerk_user)
      expect(user).to be_persisted
      expect(user.clerk_id).to eq('user_123')
      expect(user.email).to eq('john@example.com')
      expect(user.first_name).to eq('John')
      expect(user.last_name).to eq('Doe')
    end

    it 'returns existing user if clerk_id exists' do
      existing_user = create(:user, clerk_id: 'user_123')
      user = User.find_or_create_from_clerk(clerk_user)
      expect(user.id).to eq(existing_user.id)
    end

    it 'handles missing email_addresses' do
      clerk_user['email_addresses'] = nil
      user = User.find_or_create_from_clerk(clerk_user)
      expect(user.email).to include('user_123@clerk.local')
    end
  end

  describe '.update_from_clerk' do
    let(:clerk_user) do
      {
        'id' => 'user_456',
        'email_addresses' => [{ 'email_address' => 'jane@example.com' }],
        'first_name' => 'Jane',
        'last_name' => 'Smith',
        'profile_image_url' => 'https://example.com/jane.jpg'
      }
    end

    it 'updates existing user with clerk data' do
      existing_user = create(:user, clerk_id: 'user_456', first_name: 'Old Name')
      user = User.update_from_clerk(clerk_user)
      expect(user.id).to eq(existing_user.id)
      expect(user.first_name).to eq('Jane')
      expect(user.email).to eq('jane@example.com')
    end

    it 'creates user if not found' do
      user = User.update_from_clerk(clerk_user)
      expect(user).to be_persisted
      expect(user.clerk_id).to eq('user_456')
    end
  end

  describe '.active scope' do
    it 'returns users updated within 30 days' do
      active_user = create(:user, updated_at: 1.day.ago)
      inactive_user = create(:user, updated_at: 60.days.ago)

      expect(User.active).to include(active_user)
      expect(User.active).not_to include(inactive_user)
    end
  end
end

