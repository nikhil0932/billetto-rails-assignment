require 'billetto/errors'

module Billetto
  class Configuration
    attr_accessor :api_key, :api_secret, :api_base_url, :timeout, :max_retries, :retry_delay

    def initialize
      # Try to get from Rails credentials first, fall back to environment variables
      if defined?(Rails) && Rails.application.credentials.dig(:billetto)
        billetto_config = Rails.application.credentials.dig(:billetto)
        @api_key = billetto_config.dig(:api_key) || ENV.fetch('BILLETTO_API_KEY', '')
        @api_secret = billetto_config.dig(:api_secret) || ENV.fetch('BILLETTO_API_SECRET', '')
      else
        @api_key = ENV.fetch('BILLETTO_API_KEY', '')
        @api_secret = ENV.fetch('BILLETTO_API_SECRET', '')
      end

      @api_base_url = ENV.fetch('BILLETTO_API_BASE_URL', 'https://api.billetto.com')
      @timeout = ENV.fetch('BILLETTO_TIMEOUT', 30).to_i
      @max_retries = ENV.fetch('BILLETTO_MAX_RETRIES', 3).to_i
      @retry_delay = ENV.fetch('BILLETTO_RETRY_DELAY', 1).to_i
    end

    def validate!
      raise ConfigurationError, "BILLETTO_API_KEY is not set" if @api_key.blank?
      raise ConfigurationError, "BILLETTO_API_SECRET is not set" if @api_secret.blank?
    end

    def api_keypair
      "#{@api_key}:#{@api_secret}"
    end
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def config
      configuration
    end
  end
end
