require './test/test_helper'

class OnlineStatusTest < Test::Unit::TestCase
  def test_setting_online
    assert_equal 0, OnlineStatus.online_users.length
    User.create('thomas')
    user = User.find_by_name('thomas')
    OnlineStatus.online!(user)
    assert_equal [user.id.to_s], OnlineStatus.online_users
  end

  def test_feed_is_updated
    User.create('thomas');User.create('dan')
    user = User.find_by_name('thomas')
    friend = User.find_by_name('dan')
    Friending.create(user, friend)
    OnlineStatus.online!(friend)
    assert_equal 'dan logged in', $redis.lrange("#{user.key}:feed", 0, 1)[0]
  end

  def test_online_users
    6.times{|x| $redis.sadd("OnlineStatus:#{(Time.now - x * 60).strftime('%M')}", x+1)}
    assert_equal ["1", "2", "3", "4", "5"], OnlineStatus.online_users
  end
end
