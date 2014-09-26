# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack_api_key_limit/version'

Gem::Specification.new do |spec|
  spec.name          = "rack_api_key_limit"
  spec.version       = Rack::ApiKeyLimit::VERSION
  spec.authors       = ["Rich Hollis"]
  spec.email         = ["richhollis@gmail.com"]
  spec.description   = %q{Rack middleware for limiting requests based on an parameter}
  spec.summary       = %q{The middleware uses a default strategy of hourly limiting for api keys but has been designed so that you can implement your own strategies and cache stores.}
  spec.homepage      = "https://github.com/richhollis/rack_api_key_limit"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake", "~> 10"
  spec.add_development_dependency "rspec", "~> 3"
  spec.add_development_dependency "timecop", "~> 0"
  spec.add_development_dependency 'rack-test', '~> 0.5'

  spec.add_runtime_dependency     'rack',      '~> 1.0'

end
