# Billetto API Client
# Handles HTTP requests to the Billetto API with retry logic and error handling

require 'net/http'
require 'json'

module Billetto
  class Client
    API_BASE_URL = 'https://billetto.dk/api/v3/public'
    DEFAULT_TIMEOUT = 30
    DEFAULT_MAX_RETRIES = 3
    DEFAULT_RETRY_DELAY = 1

    def initialize(config = nil)
      @config = config || Billetto.config
      @timeout = @config.timeout || DEFAULT_TIMEOUT
      @max_retries = @config.max_retries || DEFAULT_MAX_RETRIES
      @retry_delay = @config.retry_delay || DEFAULT_RETRY_DELAY
    end

    # Fetch events from Billetto API
    def fetch_events(params = {})
      path = '/events'
      query_params = build_query_params(params)
      get("#{path}?#{query_params}")
    end

    private

    def get(path, retries = 0)
      uri = URI("#{API_BASE_URL}#{path}")
      
      request = Net::HTTP::Get.new(uri)
      request['Api-Keypair'] = @config.api_keypair
      request['Accept'] = 'application/json'
      request['User-Agent'] = 'BillettoRailsApp/1.0'

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = @timeout
      http.open_timeout = @timeout

      response = http.request(request)
      handle_response(response)
    rescue StandardError => e
      if retries < @max_retries
        Rails.logger.warn "Billetto API request failed (attempt #{retries + 1}/#{@max_retries}): #{e.message}"
        sleep @retry_delay
        get(path, retries + 1)
      else
        raise ClientError, "Failed to fetch from #{path} after #{@max_retries} retries: #{e.message}"
      end
    end

    def handle_response(response)
      case response.code.to_i
      when 200, 201
        parse_json(response.body)
      when 400
        data = parse_json(response.body)
        raise ClientError, "Bad request: #{data['error'] || response.body}"
      when 401
        raise ClientError, "Unauthorized: Invalid API credentials"
      when 403
        raise ClientError, "Forbidden: Access denied"
      when 404
        raise ClientError, "Not found"
      when 429
        raise ClientError, "Rate limited: Too many requests"
      when 500..599
        raise ClientError, "Server error (#{response.code}): #{response.body}"
      else
        raise ClientError, "Unexpected response code #{response.code}: #{response.body}"
      end
    end

    def parse_json(body)
      JSON.parse(body)
    rescue JSON::ParserError => e
      raise ClientError, "Failed to parse JSON response: #{e.message}"
    end

    def build_query_params(params)
      # Default parameters for fetching events
      default_params = {
        limit: params[:limit] || 50,
        offset: params[:offset] || 0
      }

      # Merge with custom params
      all_params = default_params.merge(params.except(:limit, :offset))

      # Build query string
      all_params.map { |k, v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
    end
  end

  class ClientError < StandardError; end
end


