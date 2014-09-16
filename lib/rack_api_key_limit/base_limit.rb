module RackApiKeyLimit
  class BaseLimit

    def initialize(app, options)
      @app = app
      @options = options
    end

    def call(env)
      request = Rack::Request.new(env)
      key = get_key(request)
      allowed?(request, key) ? not_rate_limited(env, request, key) : rate_limit_exceeded(key)
    end

    def param_name
      "api_key"
    end

    def get_key(request)
      raise NotImplementedError.new("You must implement get_key.")
    end

    def not_rate_limited(env, request, key)
      status, headers, response = @app.call(env)
      headers = headers.merge(rate_limit_headers(key)) if request.params[param_name]
      [status, headers, response]
    end

    def limit
      options[:limit] || 150
    end

    def limit_seconds
      raise NotImplementedError.new("You must implement limit_seconds.")
    end

    def rate_limit_headers(key)
      headers = {}
      headers["X-RateLimit-Limit"] = limit.to_s
      headers["X-RateLimit-Remaining"] = remaining(key).to_s
      headers["X-RateLimit-Reset"] = retry_after.to_f.ceil.to_s if respond_to?(:retry_after)
      headers
    end

    def rate_limit_exceeded(key)
      http_error(options[:code] || 403, options[:message] || 'Rate Limit Exceeded', rate_limit_headers(key))
    end

    def options
      @options
    end

    def redis
      options[:redis]
    end

    def request_count(key)
      count = redis.get(key)
      return count.to_i if count
      0
    end

    def remaining(key)
      limit - request_count(key)
    end

    def allowed?(request, key)
      return true if !request.params[param_name] # always allowed if no key present
      count = request_count(key)
      return false if count and count >= limit
      redis.multi do
        redis.incr(key)
        redis.expire(key, limit_seconds)
      end
      true
    end

    def http_error(code, message = nil, headers = {})
      [code, {'Content-Type' => 'text/plain; charset=utf-8'}.merge(headers),
        [http_status(code) + (message.nil? ? "\n" : " (#{message})\n")]
      ]
    end

    def http_status(code)
      [code, Rack::Utils::HTTP_STATUS_CODES[code]].join(' ')
    end

  end
end