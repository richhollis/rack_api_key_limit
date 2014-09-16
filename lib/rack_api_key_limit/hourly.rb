module Rack
  module ApiKeyLimit
    class Hourly < Base
      def get_key(request, counter)
        api_key = param(request)
        "#{param_name}-rate-limit:#{api_key}-#{Time.now.hour}"
      end

      def limit_seconds
        3600
      end

      def retry_after
        retry_after_seconds(Time.now, limit_seconds)        
      end

      def retry_after_seconds(time_now, period_seconds)
        seconds_since_midnight = time_now.to_i % 86400
        (period_seconds - seconds_since_midnight % period_seconds)
      end
    end
  end
end