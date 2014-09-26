# RackApiKeyLimit

Rack middleware for limiting requests based on an parameter - e.g. api_key

```
http://api.somewhere.com/api/v1/users?api_key=dflgjkd9o8345kdjbkcjvbij
```

The middleware uses a default strategy of hourly limiting for api keys but has been designed so that you can implement your own strategies. The default limit is 150 requests an hour.

## X-RateLimit headers

X-RateLimit headers are returned with each request where the api_key parameter is present:

<table>
  <tr>
    <td>X-RateLimit-Limit</td><td>The maximum number of requests per time period (e.g. hour)</td>
  </tr>
  <tr>
    <td>X-RateLimit-Remaining</td><td>The number of requests remaining</td>
  </tr>
  <tr>
    <td>X-RateLimit-Reset</td><td>The number of seconds until the current time period ends</td>
  </tr>
</table>

I found this artcle on Stack Overflow very useful:

http://stackoverflow.com/questions/16022624/examples-of-http-api-rate-limiting-http-response-headers

It would be pretty easy to add a ```Retry-After``` header if you wanted to.

## Cache Stores

Redis is used for the cache store but again you could easily implement your own.

## Inspiration

This rack middleware was heavily inspired and uses parts of the no longer maintained [rack-throttle](https://github.com/datagraph/rack-throttle) middleware - in particular the design and specs saved me a lot of time.

## Installation

Add this line to your application's Gemfile:

    gem 'rack_api_key_limit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack_api_key_limit

## Usage

### Rails 3 installation

config/application.rb

```
config.middleware.insert_before 'Rack::Cache', Rack::ApiKeyLimit::Hourly, {
  cache: Rack::ApiKeyLimit::Cache::Redis.new(your_redis_instance),
  request_limit: 100
}
```

## Contributing

If you are contributing, please include good test coverage for your pull request - thanks!

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
