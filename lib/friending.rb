class Friending
  # Create a friend relationship between 2 users
  def self.create(user, friended)
    $redis.sadd("#{user.key}:friends", friended.id)
    $redis.sadd("#{friended.key}:followers", user.id)
    $redis.lpush("#{friended.key}:feed", "#{user.name} added you as a friend")
  end
end
