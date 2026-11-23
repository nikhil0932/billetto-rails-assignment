require 'rails_helper'

RSpec.describe Vote, type: :model do
  describe 'associations' do
    it { should belong_to(:event) }
  end

  describe 'validations' do
    it { should validate_presence_of(:event_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:vote_type) }
  end

  describe 'vote_type' do
    let(:event) { create(:event) }

    it 'accepts upvote' do
      vote = build(:vote, event: event, vote_type: 'upvote')
      expect(vote).to be_valid
    end

    it 'accepts downvote' do
      vote = build(:vote, event: event, vote_type: 'downvote')
      expect(vote).to be_valid
    end
  end

  describe 'uniqueness' do
    let(:event) { create(:event) }
    let(:user_id) { SecureRandom.uuid }

    it 'allows different users on same event' do
      create(:vote, event: event, user_id: SecureRandom.uuid)
      vote = build(:vote, event: event, user_id: SecureRandom.uuid)
      expect(vote).to be_valid
    end

    it 'prevents duplicate votes from same user' do
      create(:vote, event: event, user_id: user_id, vote_type: 'upvote')
      vote = build(:vote, event: event, user_id: user_id, vote_type: 'upvote')
      expect(vote).not_to be_valid
    end
  end

  describe '.upvotes' do
    let(:event) { create(:event) }

    it 'returns only upvotes' do
      upvote = create(:vote, :upvote, event: event)
      downvote = create(:vote, :downvote, event: event)

      expect(Vote.upvotes).to include(upvote)
      expect(Vote.upvotes).not_to include(downvote)
    end
  end

  describe '.downvotes' do
    let(:event) { create(:event) }

    it 'returns only downvotes' do
      upvote = create(:vote, :upvote, event: event)
      downvote = create(:vote, :downvote, event: event)

      expect(Vote.downvotes).to include(downvote)
      expect(Vote.downvotes).not_to include(upvote)
    end
  end

  describe 'enum' do
    let(:event) { create(:event) }

    it 'defines upvote?' do
      vote = create(:vote, :upvote, event: event)
      expect(vote.upvote?).to be true
    end

    it 'defines downvote?' do
      vote = create(:vote, :downvote, event: event)
      expect(vote.downvote?).to be true
    end
  end
end
