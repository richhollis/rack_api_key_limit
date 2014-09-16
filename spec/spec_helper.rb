require "rack/test"
require "rack_api_key_limit"
require "timecop"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.color = true
end

def example_target_app
  app = double("Example Rack App")
  allow(app).to receive(:call).and_return([200, {}, "Example App Body"])
  app
end

def app_stub_with_options(options)
  cache = CacheStub.new
  LimiterStub.new(example_target_app, options)
end

class CacheStub
  def initialize
    @counter = 0
  end
  def increment(key, seconds)
    @counter += 1
  end
  def expire(key, time)
  end
  def get(key)
    @counter
  end
end

def spec_time
  Time.gm(2014,9,16,13,55,00)
end

class LimiterStub < Rack::ApiKeyLimit::Base
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