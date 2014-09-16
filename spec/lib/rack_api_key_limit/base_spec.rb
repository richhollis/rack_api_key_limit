require 'spec_helper'

describe Rack::ApiKeyLimit::Base do

  include Rack::Test::Methods

  let(:counter) { CounterStub.new }
  let(:app) { app_stub_with_options({}) }

  context "api_key not present" do
    before(:each) { get "/foo" }
    it "when called without param is allowed" do
      expect(last_response.body).to eq "Example App Body"
    end
    it "doesn't return X-RateLimit headers" do
      expect(last_response.headers).to eq({"Content-Length" => "16"})
    end
  end
  context "api_key present" do
    context "counter at zero" do
      it "allows call" do
        get "/foo?api_key=test"
        expect(last_response.body).to eq "Example App Body"
        expect(last_response.headers).to include({"X-RateLimit-Remaining" => "149"})
      end
      it "increments the counter" do
        Timecop.freeze { 3.times { get "/foo?api_key=test" } }
        key = "api_key-rate-limit:test-13"
        expect(app.request_count(key)).to eq 3
      end
    end
    context "counter at max limit" do
      before(:each) { 
        allow(counter).to receive(:get).and_return(150) 
        Timecop.freeze(spec_time) { get "/foo?api_key=test" }
      }
      it "returns rate limit error body" do
        expect(last_response.body).to eq "429 Too Many Requests (Rate Limit Exceeded)\n"
      end
      it "returns rate limit status code" do
        expect(last_response.status).to eq 429
      end
      it "retuns X-RateLimit headers" do
        expect(last_response.headers).to include({"X-RateLimit-Limit" => "150"})
        expect(last_response.headers).to include({"X-RateLimit-Remaining" => "0"})
        expect(last_response.headers).to include({"X-RateLimit-Reset" => "300"})
      end
    end
  end
  context "options" do
    context "param_name" do
      let(:app) { app_stub_with_options({param_name: "my_api_key"}) }
      it "uses specified param name" do
        get "/foo?my_api_key=test"
        expect(last_response.headers).to include({"X-RateLimit-Remaining" => "149"})
      end
    end
    context "request_limit" do
      let(:app) { app_stub_with_options({request_limit: 10}) }
      it "uses specified request_limit" do
        get "/foo?api_key=test"
        expect(last_response.headers).to include({"X-RateLimit-Remaining" => "9"})
      end
    end
    context "status & message" do
      let(:app) { app_stub_with_options({status: 403, message: "Rate limit!", request_limit: 0}) }
      it "uses specified status and message" do
        get "/foo?api_key=test"
        expect(last_response.body).to eq "403 Forbidden (Rate limit!)\n"
      end
    end
  end
end