require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  describe 'GET #index' do
    before { create_list(:event, 15) }

    it 'renders index' do
      get :index
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:index)
    end

    it 'assigns events' do
      get :index
      expect(assigns(:events).count).to eq(15)
    end

    context 'with auth' do
      before { @request.env['current_user'] = user }

      it 'assigns current user' do
        get :index
        expect(assigns(:current_user)).to eq(user)
      end

      it 'includes user vote data' do
        vote = create(:vote, user_id: user.clerk_id)
        get :index
        expect(assigns(:event_votes)).to include(vote.event_id)
      end
    end
  end

  describe 'GET #show' do
    it 'renders show' do
      get :show, params: { id: event.id }
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
    end

    it 'assigns event' do
      get :show, params: { id: event.id }
      expect(assigns(:event)).to eq(event)
    end

    it 'redirects if event not found' do
      get :show, params: { id: 'invalid' }
      expect(response).to redirect_to(events_url)
    end

    context 'with auth' do
      before { @request.env['current_user'] = user }

      it 'assigns user vote if exists' do
        vote = create(:vote, event: event, user_id: user.clerk_id)
        get :show, params: { id: event.id }
        expect(assigns(:user_vote)).to eq(vote)
      end

      it 'assigns nil if no vote' do
        get :show, params: { id: event.id }
        expect(assigns(:user_vote)).to be_nil
      end
    end
  end

  describe 'POST #vote' do
    it 'redirects if not authenticated' do
      post :vote, params: { id: event.id, vote_type: 'upvote' }
      expect(response).to redirect_to('/sign-in')
    end

    context 'with auth' do
      before { @request.env['current_user'] = user }

      it 'creates new vote' do
        expect {
          post :vote, params: { id: event.id, vote_type: 'upvote' }
        }.to change(Vote, :count).by(1)
      end

      it 'redirects to event show' do
        post :vote, params: { id: event.id, vote_type: 'upvote' }
        expect(response).to redirect_to(event_path(event))
      end

      it 'updates existing vote' do
        create(:vote, event: event, user_id: user.clerk_id, vote_type: 'upvote')
        post :vote, params: { id: event.id, vote_type: 'downvote' }
        expect(Vote.find_by(event: event, user_id: user.clerk_id).vote_type).to eq('downvote')
      end

      it 'removes vote if same type' do
        create(:vote, event: event, user_id: user.clerk_id, vote_type: 'upvote')
        expect {
          post :vote, params: { id: event.id, vote_type: 'upvote' }
        }.to change(Vote, :count).by(-1)
      end

      it 'rejects invalid vote_type' do
        post :vote, params: { id: event.id, vote_type: 'invalid' }
        expect(response).to redirect_to(event_path(event))
      end

      it 'redirects if event not found' do
        post :vote, params: { id: 'invalid', vote_type: 'upvote' }
        expect(response).to redirect_to(events_url)
      end
    end
  end
end
