class SessionsController < ApplicationController
  def new
    render :new
  end

  def signup
    render :signup
  end

  def create
    user = User.find_by(clerk_id: params[:clerk_id])
    if user
      session[:user_id] = user.id
      redirect_to root_path, notice: 'Signed in successfully'
    else
      redirect_to '/sign-in', alert: 'User not found'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: 'Signed out'
  end
end

