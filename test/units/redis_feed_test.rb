require './test/test_helper'

class RedisFeedTest < Test::Unit::TestCase

  def test_index
    get '/'
    assert last_response.ok?
  end

  def test_user_profile_with_non_existant_user
    get '/users/thomas'
    assert last_response.not_found?
  end

  def test_user_profile_with_user
    User.create('thomas')
    get '/users/thomas'
    assert last_response.ok?
    assert_equal '1', $redis.get('User:1:views')
  end

  def test_all_users
    get '/users'
    assert last_response.ok?
  end

  def test_signin_with_bad_credentials
    post '/signin', :name => 'thomas'
    assert last_response.not_found?
  end

  def test_signin_with_good_credentials
    User.create('thomas')
    post '/signin', :name => 'thomas'
    follow_redirect!
    assert_equal 'http://example.org/', last_request.url
  end

  def test_signout
    post 'signout'
    follow_redirect!
    assert_equal 'http://example.org/', last_request.url
  end

  def test_signup
    post '/signup', :name => 'thomas'
    follow_redirect!
    assert_equal 'http://example.org/', last_request.url
    assert_equal 'thomas', $redis.get("User:1:username")
    assert_equal "1", $redis.get("User:thomas")
    assert_equal ["1"], $redis.smembers('Users')
  end

  def test_updates
    User.create('thomas')
    as_logged_in 'thomas' do
      post '/updates', :update => 'Hello world'
      follow_redirect!
      assert_equal 'Hello world', $redis.get('Update:1')
      assert_equal 'http://example.org/', last_request.url
    end
  end

  def test_friends
    User.create('thomas'); User.create('bob')
    as_logged_in 'thomas' do
      post '/friends', {:id => '2'}
      follow_redirect!
      assert_equal 'http://example.org/users/bob', last_request.url
      assert_equal ['2'], $redis.smembers("User:1:friends")
      assert_equal ['1'], $redis.smembers("User:2:followers")
    end
  end
end
