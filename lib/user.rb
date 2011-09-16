class User
  
  attr_accessor :id

  def initialize(id)
    @id = id
  end

  # Find a user by name
  def self.find_by_name(name)
    if id = $redis.get("User:#{name}")
      self.new(id)
    else
      nil
    end
  end

  # Find a user by id
  def self.find(id)
    if $redis.sismember('Users', id)
      self.new(id)
    else
      nil
    end
  end

  # Create a user
  def self.create(username)
    id = $redis.incr 'User:nextId' # Get next id
    $redis.set("User:#{id}:username", username) # Store username
    $redis.set("User:#{username}", id) # Store id for username lookup
    $redis.sadd('Users', id) # Add to all users
  end

  # Return all users
  def self.all
    users = []
    $redis.smembers('Users').each do |u|
      users << self.new(u)
    end
    users
  end

  # Key to namespace keys with
  def key
    "User:#{@id}"
  end

  # Return username
  def name
    $redis.get("#{key}:username")
  end

  # Return friends that are online
  def online_friends
    users = []
    OnlineStatus.online_users
    $redis.sinter("#{key}:friends", "OnlineUsers").each do |u|
      users << User.new(u)
    end
    users
  end

  # Return feed
  def feed
    $redis.lrange("#{key}:feed", 0, -1)
  end

  # Add a profile view
  def profile_viewed!
    $redis.incr "#{key}:views"
  end

  # No of profile views
  def profile_views
    $redis.get("#{key}:views") || "0"
  end

  # All friends
  def friends
    $redis.smembers("#{key}:friends").collect{|f| User.new(f)}
  end

  # Are you friends with this user?
  def friends_with?(user)
    $redis.sismember("#{key}:friends", user.id) 
  end

  # Users you are both friends with
  def both_follow(id)
    $redis.sinter("#{key}:friends", "User:#{id}:friends")
  end

  # All updates
  def updates
    $redis.lrange("#{key}:updates", 0, -1).collect{|u| Update.new(u)}
  end
end
