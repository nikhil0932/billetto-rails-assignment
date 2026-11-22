module Billetto
  # Base error class for Billetto API errors
  class APIError < StandardError
    attr_reader :status_code, :response_body

    def initialize(message, status_code = nil, response_body = nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end

  # Client error
  class ClientError < StandardError; end

  # 404 Not Found
  class NotFoundError < APIError
    def initialize(message = "Resource not found", response_body = nil)
      super(message, 404, response_body)
    end
  end

  # 5xx Server Error
  class ServerError < APIError
    def initialize(message = "Server error", status_code = 500, response_body = nil)
      super(message, status_code, response_body)
    end
  end

  # Request timeout
  class TimeoutError < APIError
    def initialize(message = "Request timeout")
      super(message, nil, nil)
    end
  end

  # Rate limit exceeded
  class RateLimitError < APIError
    attr_reader :retry_after

    def initialize(message = "Rate limit exceeded", retry_after = nil)
      super(message, 429, nil)
      @retry_after = retry_after
    end
  end

  # Invalid request (4xx errors excluding 404 and 429)
  class InvalidRequestError < APIError
    def initialize(message, status_code = 400, response_body = nil)
      super(message, status_code, response_body)
    end
  end

  # Configuration error
  class ConfigurationError < StandardError; end
end
