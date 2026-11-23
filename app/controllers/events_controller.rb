class EventsController < ApplicationController
  before_action :set_event, only: [:show, :vote]
  before_action :authenticate_user!, only: [:vote]

  # GET /events
  # List all events with voting statistics
  def index
    @events = Event.order(start_date: :desc)

    @event_votes = current_user ? Vote.where(user_id: current_user.clerk_id).pluck(:event_id, :vote_type).to_h : {}
  end

  # GET /events/:id
  # Show event detail with voting UI
  def show
    @user_vote = current_user ? current_user.votes.find_by(event: @event) : nil
    @total_voters = @event.votes.distinct.count(:user_id)
  end

  # POST /events/:id/vote
  # Create or update user's vote on an event
  def vote
    vote_type = params[:vote_type]

    # Validate vote_type
    unless %w[upvote downvote].include?(vote_type)
      return redirect_to @event, alert: 'Invalid vote type'
    end

    # Find or create vote
    @vote = Vote.find_or_initialize_by(event: @event, user_id: current_user.clerk_id)

    if @vote.vote_type == vote_type
      # Same vote - remove it
      @vote.destroy
      message = "Vote removed"
    else
      # Update or create vote
      @vote.vote_type = vote_type
      if @vote.save
        message = "#{vote_type.capitalize} recorded!"
      else
        return redirect_to @event, alert: "Error saving vote: #{@vote.errors.full_messages.join(', ')}"
      end
    end

    respond_to do |format|
      format.html { redirect_to @event, notice: message }
      format.turbo_stream
      format.json { render json: { status: 'ok', message: message } }
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to events_url, alert: 'Event not found'
  end
end
