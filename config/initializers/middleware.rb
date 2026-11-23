# frozen_string_literal: true

# Load the middleware class before registering it
require_dependency 'clerk_auth'

# Register Clerk authentication middleware after Session so we can access session data
# Middleware order: Cookies -> Session -> ClerkAuth
Rails.application.config.middleware.insert_after(
  ActionDispatch::Session::CookieStore,
  ClerkAuth
)


