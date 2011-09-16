require './test/test_helper'

class UpdateTest < Test::Unit::TestCase
  def setup
    User.create('thomas')
    @user = User.find_by_name('thomas')
    Update.create(@user, 'Hello world')
  end

  def test_creating_update
    assert_equal 'Hello world', $redis.get('Update:1')
    assert_equal ['1'], $redis.lrange("#{@user.key}:updates", 0, -1)
  end

  def test_feed_is_updated
    User.create('dan')
    friend = User.find_by_name('dan')
    Friending.create(@user, friend)
    Update.create(friend, 'Hello')
    assert_equal 'dan posted an update', $redis.lrange("#{@user.key}:feed", 0, 1)[0]
  end

  def test_getting_update
    assert_equal 'Hello world', Update.find(1).update
  end

  def test_find
    update = Update.find(1)
    assert_equal 'Hello world', update.update
  end
end
