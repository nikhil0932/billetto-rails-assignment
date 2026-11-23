# frozen_string_literal: true

# Clerk.com Configuration
begin
  require 'clerk'
  
  Clerk.configure do |config|
    config.api_key = Rails.application.credentials.dig(:clerk, :secret_key) || ENV['CLERK_SECRET_KEY']
  end
rescue LoadError => e
  Rails.logger.warn("Clerk SDK not loaded: #{e.message}")
end

