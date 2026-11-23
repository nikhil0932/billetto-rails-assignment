require 'rails_helper'

RSpec.describe 'Events Requests', type: :request do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  describe 'GET /events' do
    before { create_list(:event, 5) }

    it 'returns http success' do
      get '/events'
      expect(response).to have_http_status(:success)
    end

    it 'returns HTML content' do
      get '/events'
      expect(response.content_type).to include('text/html')
    end

    it 'renders events index' do
      get '/events'
      expect(response.body).to include('Billetto Events')
    end

    it 'displays event titles' do
      event = create(:event, title: 'Amazing Concert')
      get '/events'
      expect(response.body).to include('Amazing Concert')
    end
  end

  describe 'GET /events/:id' do
    it 'returns http success for valid event' do
      get "/events/#{event.id}"
      expect(response).to have_http_status(:success)
    end

    it 'displays event details' do
      get "/events/#{event.id}"
      expect(response.body).to include(event.title)
      # Description is formatted with <br /> for newlines, so just check for a part of it
      expect(response.body).to include('About This Event')
    end

    it 'returns redirect for invalid event' do
      get '/events/999999'
      expect(response).to redirect_to(events_url)
    end
  end

  describe 'POST /events/:id/vote' do
    context 'without authentication' do
      it 'redirects to sign-in' do
        post "/events/#{event.id}/vote", params: { vote_type: 'upvote' }
        expect(response).to redirect_to('/sign-in')
      end
    end

    context 'with authentication' do
      before do
        # Simulate authenticated request
        # In real scenario, Clerk middleware would set this
        allow_any_instance_of(EventsController).to receive(:current_user).and_return(user)
        allow_any_instance_of(EventsController).to receive(:user_signed_in?).and_return(true)
      end

      it 'creates vote on upvote' do
        expect {
          post "/events/#{event.id}/vote", params: { vote_type: 'upvote' }
        }.to change(Vote, :count).by(1)
      end

      it 'creates vote on downvote' do
        expect {
          post "/events/#{event.id}/vote", params: { vote_type: 'downvote' }
        }.to change(Vote, :count).by(1)
      end

      it 'redirects after successful vote' do
        post "/events/#{event.id}/vote", params: { vote_type: 'upvote' }
        expect(response).to redirect_to(event_path(event))
      end

      it 'does not create vote with invalid type' do
        expect {
          post "/events/#{event.id}/vote", params: { vote_type: 'invalid' }
        }.not_to change(Vote, :count)
      end
    end
  end

  describe 'Root path' do
    it 'serves events index' do
      get '/'
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Billetto Events')
    end
  end
end
