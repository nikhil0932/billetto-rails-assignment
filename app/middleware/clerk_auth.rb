# frozen_string_literal: true

class ClerkAuth
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    session = env['rack.session'] || {}
    
    if session['user_id'].present?
      user = User.find_by(id: session['user_id'])
      env['current_user'] = user if user
    end

    @app.call(env)
  end
end

