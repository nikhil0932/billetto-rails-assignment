require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  describe 'GET #index' do
    before { create_list(:event, 15) }

    context 'without authentication' do
      it 'returns http success' do
        get :index
        expect(response).to have_http_status(:success)
      end

      it 'renders the index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'assigns all events' do
        get :index
        expect(assigns(:events).count).to eq(15)
      end

      it 'does not set event_votes' do
        get :index
        expect(assigns(:event_votes)).to be_empty
      end
    end

    context 'with authentication' do
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
    context 'with valid event' do
      it 'returns http success' do
        get :show, params: { id: event.id }
        expect(response).to have_http_status(:success)
      end

      it 'renders the show template' do
        get :show, params: { id: event.id }
        expect(response).to render_template(:show)
      end

      it 'assigns event' do
        get :show, params: { id: event.id }
        expect(assigns(:event)).to eq(event)
      end

      it 'assigns total_voters' do
        create(:vote, event: event, user_id: 'user_1')
        create(:vote, event: event, user_id: 'user_2')
        get :show, params: { id: event.id }
        expect(assigns(:total_voters)).to eq(2)
      end
    end

    context 'with invalid event' do
      it 'redirects to index' do
        get :show, params: { id: 'invalid' }
        expect(response).to redirect_to(events_url)
      end

      it 'sets flash alert' do
        get :show, params: { id: 'invalid' }
        expect(flash[:alert]).to match('not found')
      end
    end

    context 'when user is authenticated' do
      before { @request.env['current_user'] = user }

      it 'assigns user vote if exists' do
        vote = create(:vote, event: event, user_id: user.clerk_id)
        get :show, params: { id: event.id }
        expect(assigns(:user_vote)).to eq(vote)
      end

      it 'assigns nil if user has no vote' do
        get :show, params: { id: event.id }
        expect(assigns(:user_vote)).to be_nil
      end
    end
  end

  describe 'POST #vote' do
    context 'without authentication' do
      it 'redirects to sign-in' do
        post :vote, params: { id: event.id, vote_type: 'upvote' }
        expect(response).to redirect_to('/sign-in')
      end
    end

    context 'with authentication' do
      before { @request.env['current_user'] = user }

      context 'with valid vote_type' do
        it 'creates new vote' do
          expect {
            post :vote, params: { id: event.id, vote_type: 'upvote' }
          }.to change(Vote, :count).by(1)
        end

        it 'redirects to event show' do
          post :vote, params: { id: event.id, vote_type: 'upvote' }
          expect(response).to redirect_to(event_path(event))
        end

        it 'sets success notice' do
          post :vote, params: { id: event.id, vote_type: 'upvote' }
          expect(flash[:notice]).to match('recorded')
        end

        it 'updates existing vote' do
          create(:vote, event: event, user_id: user.clerk_id, vote_type: 'upvote')
          expect {
            post :vote, params: { id: event.id, vote_type: 'downvote' }
          }.not_to change(Vote, :count)

          expect(Vote.find_by(event: event, user_id: user.clerk_id).vote_type).to eq('downvote')
        end

        it 'removes vote if same type' do
          create(:vote, event: event, user_id: user.clerk_id, vote_type: 'upvote')
          expect {
            post :vote, params: { id: event.id, vote_type: 'upvote' }
          }.to change(Vote, :count).by(-1)
        end
      end

      context 'with invalid vote_type' do
        it 'does not create vote' do
          expect {
            post :vote, params: { id: event.id, vote_type: 'invalid' }
          }.not_to change(Vote, :count)
        end

        it 'redirects to event show' do
          post :vote, params: { id: event.id, vote_type: 'invalid' }
          expect(response).to redirect_to(event_path(event))
        end

        it 'sets alert message' do
          post :vote, params: { id: event.id, vote_type: 'invalid' }
          expect(flash[:alert]).to match('Invalid')
        end
      end

      context 'with invalid event' do
        it 'redirects to events index' do
          post :vote, params: { id: 'invalid', vote_type: 'upvote' }
          expect(response).to redirect_to(events_url)
        end
      end
    end

    context 'JSON response' do
      before { @request.env['current_user'] = user }

      it 'returns JSON on success' do
        post :vote, params: { id: event.id, vote_type: 'upvote', format: :json }
        expect(response.content_type).to include('application/json')
        expect(JSON.parse(response.body)['status']).to eq('ok')
      end
    end
  end
end
