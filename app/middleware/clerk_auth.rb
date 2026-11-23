# frozen_string_literal: true

class ClerkAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)

    session = env['rack.session']
    
    # Try to get user_id from session - handle both Symbol and String keys
    user_id = session['user_id'] || session[:user_id] if session
    
    if user_id.present?
      user = User.find_by(id: user_id)
      if user
        env['current_user'] = user
        env['clerk_user_id'] = user.clerk_id
        return @app.call(env)
      end
    end
    
    # Try to extract and verify Clerk session
    session_token = extract_session_token(request)
    
    if session_token
      begin
        # Verify the session token using Clerk SDK
        clerk_config = Rails.application.credentials.dig(:clerk, :secret_key) || ENV['CLERK_SECRET_KEY']
        clerk_sdk = Clerk::SDK.new(api_key: clerk_config)
        
        session = clerk_sdk.sessions.verify_token(session_token)
        
        if session&.user_id
          # Fetch or create user from Clerk
          clerk_user = clerk_sdk.users.read(session.user_id)
          user = User.update_from_clerk(clerk_user)
          env['current_user'] = user
          env['clerk_user_id'] = session.user_id
        end
      rescue StandardError => e
        Rails.logger.debug("Clerk auth error: #{e.message}")
        # Continue without authentication if token verification fails
      end
    end

    # Call the next middleware
    @app.call(env)
  end

  private

  def extract_session_token(request)
    # Try to get from Authorization header first (Bearer token)
    auth_header = request.env['HTTP_AUTHORIZATION']
    return auth_header.sub(/^Bearer\s+/, '') if auth_header&.start_with?('Bearer ')

    # Try to get from __session cookie (Clerk default)
    request.cookies['__session']
  end
end

