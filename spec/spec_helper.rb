require "rack/test"
require "rack_api_key_limit"
require "timecop"

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

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

def spec_time
  Time.gm(2014,9,16,13,55,00)
end
