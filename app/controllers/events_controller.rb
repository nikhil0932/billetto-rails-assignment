class EventsController < ApplicationController
  before_action :set_event, only: [:show, :vote]
  before_action :authenticate_user!, only: [:vote]

  def index
    @events = Event.order(start_date: :desc)
    @event_votes = user_signed_in? ? Vote.where(user_id: current_user.clerk_id).pluck(:event_id, :vote_type).to_h : {}
  end

  def show
    @user_vote = user_signed_in? ? current_user.votes.find_by(event: @event) : nil
    @total_voters = @event.votes.distinct.count(:user_id)
  end

  def vote
    vote_type = params[:vote_type]

    unless %w[upvote downvote].include?(vote_type)
      return redirect_to @event, alert: 'Invalid vote type'
    end

    @vote = Vote.find_or_initialize_by(event: @event, user_id: current_user.clerk_id)

    if @vote.vote_type == vote_type
      @vote.destroy
      message = "Vote removed"
    else
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
