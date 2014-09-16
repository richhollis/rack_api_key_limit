require 'spec_helper'

describe Rack::ApiKeyLimit::Hourly do

  include Rack::Test::Methods

  let(:cache) { CacheStub.new }
  let(:app) { described_class.new(example_target_app, {cache: cache}) }

  describe "#get_key" do
    it "returns expected format" do
      request = double("request object")
      allow(request).to receive(:params).and_return({"api_key" => "ABC" })
      Timecop.freeze(spec_time) { 
        expect(app.get_key(request, cache)).to eq("api_key-rate-limit:ABC-13")
      }
    end
  end
  describe "#retry_after_seconds" do
    it "returns correct value for minute remaining" do
      expect(app.retry_after_seconds(Time.gm(2014,9,16,16,59,00), 3600)).to eq(60)
    end
    it "returns correct value for hour remaining" do
      expect(app.retry_after_seconds(Time.gm(2014,9,16,00,00,00), 3600)).to eq(3600)
    end
  end
end