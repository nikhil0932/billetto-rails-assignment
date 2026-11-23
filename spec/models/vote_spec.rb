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

  describe 'vote_type validation' do
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

  describe 'uniqueness validation' do
    let(:event) { create(:event) }
    let(:user_id) { SecureRandom.uuid }

    it 'allows different users to vote on the same event' do
      create(:vote, event: event, user_id: SecureRandom.uuid, vote_type: 'upvote')
      vote = build(:vote, event: event, user_id: SecureRandom.uuid, vote_type: 'upvote')
      expect(vote).to be_valid
    end

    it 'prevents duplicate upvotes from same user on same event' do
      create(:vote, event: event, user_id: user_id, vote_type: 'upvote')
      vote = build(:vote, event: event, user_id: user_id, vote_type: 'upvote')
      expect(vote).not_to be_valid
    end

    it 'allows same user to have different vote types on same event' do
      create(:vote, event: event, user_id: user_id, vote_type: 'upvote')
      vote = build(:vote, event: event, user_id: user_id, vote_type: 'downvote')
      expect(vote).to be_valid
    end

    it 'allows same user to vote on different events' do
      event2 = create(:event)
      create(:vote, event: event, user_id: user_id, vote_type: 'upvote')
      vote = build(:vote, event: event2, user_id: user_id, vote_type: 'upvote')
      expect(vote).to be_valid
    end
  end

  describe 'scopes' do
    let(:event) { create(:event) }

    describe '.upvotes' do
      it 'returns only upvotes' do
        upvote = create(:vote, :upvote, event: event)
        downvote = create(:vote, :downvote, event: event)

        expect(Vote.upvotes).to include(upvote)
        expect(Vote.upvotes).not_to include(downvote)
      end
    end

    describe '.downvotes' do
      it 'returns only downvotes' do
        upvote = create(:vote, :upvote, event: event)
        downvote = create(:vote, :downvote, event: event)

        expect(Vote.downvotes).to include(downvote)
        expect(Vote.downvotes).not_to include(upvote)
      end
    end
  end

  describe 'enum' do
    let(:event) { create(:event) }

    it 'defines upvote enum value' do
      vote = create(:vote, :upvote, event: event)
      expect(vote.upvote?).to be true
      expect(vote.downvote?).to be false
    end

    it 'defines downvote enum value' do
      vote = create(:vote, :downvote, event: event)
      expect(vote.downvote?).to be true
      expect(vote.upvote?).to be false
    end
  end
end
