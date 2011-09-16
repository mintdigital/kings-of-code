require File.expand_path('../redis-feed', File.dirname(__FILE__))
require 'test/unit'
require 'rack/test'
ENV['RACK_ENV'] = 'test'

module RedisFeedTestHelpers
  private
  def as_logged_in(name, &block)
    post '/signin', :name => name
    yield
  end
end

class Test::Unit::TestCase
  include Rack::Test::Methods
  include RedisFeedTestHelpers

  def setup
    $redis = Redis.new(:db => 1)
  end

  def teardown
    $redis.flushdb
  end

  def app
    Sinatra::Application
  end
end
