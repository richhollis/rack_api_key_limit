module Rack
  module ApiKeyLimit
    class Base
      def initialize(app, counter, options)
        @app = app
        @counter = counter
        @options = options
      end

      def options
        @options || {}
      end

      def counter
        @counter
      end

      def call(env)
        request = Rack::Request.new(env)
        key = get_key(request, counter)
        allowed?(request, key) ? not_rate_limited(env, request, key) : rate_limit_exceeded(key)
      end

      def param_name
        options[:param_name] || "api_key"
      end

      def param(request)
        request.params[param_name]
      end

      def has_param?(request)
        request.params.has_key?(param_name)
      end

      def get_key(request, counter)
        raise NotImplementedError.new("You must implement get_key.")
      end

      def not_rate_limited(env, request, key)
        status, headers, response = @app.call(env)
        headers = headers.merge(rate_limit_headers(key)) if has_param?(request)
        [status, headers, response]
      end

      def request_limit
        options[:request_limit] || 150
      end

      def limit_seconds
        raise NotImplementedError.new("You must implement limit_seconds.")
      end

      def rate_limit_headers(key)
        headers = {}
        headers["X-RateLimit-Limit"] = request_limit.to_s
        headers["X-RateLimit-Remaining"] = remaining(key).to_s
        headers["X-RateLimit-Reset"] = retry_after.to_f.ceil.to_s if respond_to?(:retry_after)
        headers
      end

      def rate_limit_exceeded(key)
        http_error(options[:status] || 429, options[:message] || 'Rate Limit Exceeded', rate_limit_headers(key))
      end

      def request_count(key)
        request_count = counter.get(key)
        (request_count.to_i if request_count) || 0
      end

      def remaining(key)
        request_limit - request_count(key)
      end

      def allowed?(request, key)
        return true unless has_param?(request) # always allowed if no key present
        counter.increment(key, limit_seconds) and return true if remaining(key) > 0
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
end