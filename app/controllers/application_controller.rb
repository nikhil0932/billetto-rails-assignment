class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  
  helper_method :user_signed_in?, :current_user

  private

  def user_signed_in?
    request.env['current_user'].present?
  end

  def current_user
    request.env['current_user']
  end

  def authenticate_user!
    redirect_to '/sign-in' unless user_signed_in?
  end
end
