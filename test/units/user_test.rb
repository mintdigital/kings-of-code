require './test/test_helper'

class UserTest < Test::Unit::TestCase
  def test_create_user
    assert user = User.create('thomas')
    assert_equal 1, $redis.scard('Users')
    assert_equal 'thomas', $redis.get('User:1:username')
    assert_equal '1', $redis.get('User:thomas')
  end

  def test_find
    assert !User.find(1)
    User.create('thomas')
    user = User.find(1)
    assert_equal 1, user.id
    assert_equal 'thomas', user.name
  end

  def test_find_by_name
    assert !User.find_by_name('thomas')
    User.create('thomas')
    user = User.find_by_name('thomas')
    assert_equal "1", user.id
    assert_equal 'thomas', user.name
  end

  def test_find_all
    assert_equal [], User.all
    User.create('thomas')
    assert_equal 1, User.all.length
    assert_equal 'thomas', User.all.first.name
  end

  def test_name
    User.create('thomas')
    user = User.find(1)
    assert_equal 'thomas', user.name
  end

  def test_view_profile
    User.create('thomas')
    user = User.find(1)
    user.profile_viewed!
    assert_equal '1', $redis.get('User:1:views')
    user.profile_viewed!
    assert_equal '2', $redis.get('User:1:views')
  end
end
