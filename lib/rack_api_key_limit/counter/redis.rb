module Rack
  module ApiKeyLimit
    module Counter
      class Redis
        def initialize(redis)
          @redis = redis
        end

        def get(key)
          @redis.get(key)
        end

        def increment(key, limit_seconds)
          @redis.multi do
            @redis.incr(key)
            @redis.expire(key, limit_seconds)
          end
        end
      end
    end
  end
end