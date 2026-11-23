require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { should have_many(:votes).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:billetto_id) }
    it do
      create(:event)
      should validate_uniqueness_of(:billetto_id).case_insensitive
    end
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
    it { should validate_numericality_of(:price).is_greater_than_or_equal_to(0).allow_nil }
  end

  describe '#upvote_count' do
    let(:event) { create(:event) }

    it 'returns the count of upvotes' do
      create_list(:vote, 3, :upvote, event: event)
      expect(event.upvote_count).to eq(3)
    end

    it 'returns 0 when no upvotes exist' do
      expect(event.upvote_count).to eq(0)
    end

    it 'does not count downvotes' do
      create_list(:vote, 2, :upvote, event: event)
      create_list(:vote, 3, :downvote, event: event)
      expect(event.upvote_count).to eq(2)
    end
  end

  describe '#downvote_count' do
    let(:event) { create(:event) }

    it 'returns the count of downvotes' do
      create_list(:vote, 2, :downvote, event: event)
      expect(event.downvote_count).to eq(2)
    end

    it 'returns 0 when no downvotes exist' do
      expect(event.downvote_count).to eq(0)
    end

    it 'does not count upvotes' do
      create_list(:vote, 2, :upvote, event: event)
      create_list(:vote, 3, :downvote, event: event)
      expect(event.downvote_count).to eq(3)
    end
  end

  describe '#vote_score' do
    let(:event) { create(:event) }

    it 'returns positive score when upvotes > downvotes' do
      create_list(:vote, 5, :upvote, event: event)
      create_list(:vote, 2, :downvote, event: event)
      expect(event.vote_score).to eq(3)
    end

    it 'returns negative score when downvotes > upvotes' do
      create_list(:vote, 2, :upvote, event: event)
      create_list(:vote, 5, :downvote, event: event)
      expect(event.vote_score).to eq(-3)
    end

    it 'returns 0 when votes are balanced' do
      create_list(:vote, 3, :upvote, event: event)
      create_list(:vote, 3, :downvote, event: event)
      expect(event.vote_score).to eq(0)
    end

    it 'returns 0 when no votes exist' do
      expect(event.vote_score).to eq(0)
    end
  end

  describe '#already_voted_by?' do
    let(:event) { create(:event) }
    let(:user_id) { SecureRandom.uuid }

    it 'returns true if user has voted' do
      create(:vote, event: event, user_id: user_id)
      expect(event.already_voted_by?(user_id)).to be true
    end

    it 'returns false if user has not voted' do
      expect(event.already_voted_by?(user_id)).to be false
    end

    it 'returns true for any vote type by the user' do
      create(:vote, :upvote, event: event, user_id: user_id)
      expect(event.already_voted_by?(user_id)).to be true
    end
  end

  describe '#user_vote' do
    let(:event) { create(:event) }
    let(:user_id) { SecureRandom.uuid }

    it 'returns the vote type for a user' do
      create(:vote, :upvote, event: event, user_id: user_id)
      expect(event.user_vote(user_id)).to eq('upvote')
    end

    it 'returns downvote if user downvoted' do
      create(:vote, :downvote, event: event, user_id: user_id)
      expect(event.user_vote(user_id)).to eq('downvote')
    end

    it 'returns nil if user has not voted' do
      expect(event.user_vote(user_id)).to be_nil
    end
  end

  describe 'scopes' do
    describe '.upcoming' do
      it 'returns events with start_date in the future' do
        upcoming_event = create(:event, start_date: 2.days.from_now)
        past_event = create(:event, start_date: 2.days.ago)

        expect(Event.upcoming).to include(upcoming_event)
        expect(Event.upcoming).not_to include(past_event)
      end

      it 'orders by start_date ascending' do
        event1 = create(:event, start_date: 3.days.from_now)
        event2 = create(:event, start_date: 1.day.from_now)

        expect(Event.upcoming).to eq([event2, event1])
      end
    end

    describe '.past' do
      it 'returns events with end_date in the past' do
        past_event = create(:event, end_date: 2.days.ago)
        upcoming_event = create(:event, end_date: 2.days.from_now)

        expect(Event.past).to include(past_event)
        expect(Event.past).not_to include(upcoming_event)
      end

      it 'orders by end_date descending' do
        event1 = create(:event, end_date: 3.days.ago)
        event2 = create(:event, end_date: 1.day.ago)

        expect(Event.past).to eq([event2, event1])
      end
    end

    describe '.recent' do
      it 'orders by fetched_at descending' do
        event1 = create(:event, fetched_at: 1.hour.ago)
        event2 = create(:event, fetched_at: 1.minute.ago)

        expect(Event.recent).to eq([event2, event1])
      end
    end
  end

  describe 'currency validation' do
    it 'accepts valid currencies' do
      event = build(:event, currency: 'GBP')
      expect(event).to be_valid
    end

    it 'rejects invalid currencies' do
      event = build(:event, currency: 'XYZ')
      expect(event).not_to be_valid
    end

    it 'accepts nil currency' do
      event = build(:event, currency: nil)
      expect(event).to be_valid
    end
  end
end
