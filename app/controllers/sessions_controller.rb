class SessionsController < ApplicationController
  # GET /sign-in
  def new
    render :new
  end

  # GET /sign-up
  def signup
    render :signup
  end

  # GET /sign-out
  def destroy
    redirect_to root_path, notice: 'You have been signed out.'
  end
end

