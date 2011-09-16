class OnlineStatus
  # Mark a user as online
  def self.online!(user)
    key = "OnlineStatus:#{Time.now.strftime('%M')}"
    $redis.sadd(key, user.id)
    $redis.expire(key, 600) # Set key to expire after 600s
    $redis.smembers("#{user.key}:followers").each do |f|
      $redis.lpush("#{User.find(f).key}:feed", "#{user.name} logged in")
    end # Update followers activity feeds
  end

  # Return online users
  # That is a unique set of users that were online in the last 5 mins
  # N.b. in reality we would want to mark a user as online after every
  # action to have this be more accurate
  def self.online_users
    keys = 5.times.collect{|x| "OnlineStatus:#{(Time.now - x * 60).strftime('%M')}"}
    $redis.sunionstore("OnlineUsers", *keys)
    $redis.smembers("OnlineUsers")
  end
end
