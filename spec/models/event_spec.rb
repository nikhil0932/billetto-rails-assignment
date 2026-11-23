require 'rails_helper'

RSpec.describe Event, type: :model do
  describe 'associations' do
    it { should have_many(:votes).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:billetto_id) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:start_date) }
    it { should validate_presence_of(:end_date) }
  end

  describe '#upvote_count' do
    let(:event) { create(:event) }

    it 'counts upvotes' do
      create_list(:vote, 3, :upvote, event: event)
      expect(event.upvote_count).to eq(3)
    end

    it 'returns 0 when no upvotes' do
      expect(event.upvote_count).to eq(0)
    end
  end

  describe '#downvote_count' do
    let(:event) { create(:event) }

    it 'counts downvotes' do
      create_list(:vote, 2, :downvote, event: event)
      expect(event.downvote_count).to eq(2)
    end

    it 'returns 0 when no downvotes' do
      expect(event.downvote_count).to eq(0)
    end
  end

  describe '#vote_score' do
    let(:event) { create(:event) }

    it 'returns positive score' do
      create_list(:vote, 5, :upvote, event: event)
      create_list(:vote, 2, :downvote, event: event)
      expect(event.vote_score).to eq(3)
    end

    it 'returns negative score' do
      create_list(:vote, 2, :upvote, event: event)
      create_list(:vote, 5, :downvote, event: event)
      expect(event.vote_score).to eq(-3)
    end

    it 'returns 0 when no votes' do
      expect(event.vote_score).to eq(0)
    end
  end

  describe '#already_voted_by?' do
    let(:event) { create(:event) }
    let(:user_id) { SecureRandom.uuid }

    it 'returns true if user voted' do
      create(:vote, event: event, user_id: user_id)
      expect(event.already_voted_by?(user_id)).to be true
    end

    it 'returns false if user not voted' do
      expect(event.already_voted_by?(user_id)).to be false
    end
  end

  describe '#user_vote' do
    let(:event) { create(:event) }
    let(:user_id) { SecureRandom.uuid }

    it 'returns vote type' do
      create(:vote, :upvote, event: event, user_id: user_id)
      expect(event.user_vote(user_id)).to eq('upvote')
    end

    it 'returns nil if no vote' do
      expect(event.user_vote(user_id)).to be_nil
    end
  end

  describe '.upcoming' do
    it 'returns future events ordered by date' do
      upcoming = create(:event, start_date: 2.days.from_now)
      past = create(:event, start_date: 2.days.ago)

      expect(Event.upcoming).to include(upcoming)
      expect(Event.upcoming).not_to include(past)
    end
  end

  describe '.past' do
    it 'returns past events' do
      past = create(:event, end_date: 2.days.ago)
      upcoming = create(:event, end_date: 2.days.from_now)

      expect(Event.past).to include(past)
      expect(Event.past).not_to include(upcoming)
    end
  end
end
