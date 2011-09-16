require './test/test_helper'

class FriendingTest < Test::Unit::TestCase
  def test_should_create_friending
    User.create('thomas'); User.create('bob')
    friender = User.find_by_name('thomas')
    friended = User.find_by_name('bob')

    assert Friending.create(friender, friended)
    assert_equal [friended.id.to_s], $redis.smembers("#{friender.key}:friends")
    assert_equal [friender.id.to_s], $redis.smembers("#{friended.key}:followers")
    assert_equal "thomas added you as a friend", $redis.lrange("#{friended.key}:feed", 0, 1)[0]
  end
end
