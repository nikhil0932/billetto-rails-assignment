# Billetto API Configuration
# This initializer configures the Billetto API client with credentials
# stored securely in Rails credentials.

require_relative '../../lib/billetto'

Billetto.configure do |config|
  # Credentials are loaded from config/credentials.yml.enc
  # Set them with: bin/rails credentials:edit
  # Then add:
  #   billetto:
  #     api_key: YOUR_API_KEY
  #     api_secret: YOUR_API_SECRET
end

# Validate configuration in production
if Rails.env.production?
  Billetto.configuration.validate!
end
