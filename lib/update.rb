class Update
  attr_accessor :id

  def initialize(id)
    @id = id
  end

  # Find an update
  def self.find(id)
    if $redis.get("Update:#{id}")
      self.new(id)
    else
      nil
    end
  end

  # Create an update for a user
  def self.create(user, update)
    id = $redis.incr('Update:nextId') # Get next id
    $redis.set("Update:#{id}", update) # Store the update
    $redis.lpush("#{user.key}:updates", id) # Push the update to the users updates
    $redis.smembers("#{user.key}:followers").each do |f|
      $redis.lpush("#{User.find(f).key}:feed", "#{user.name} posted an update")
    end # Update followers activity feeds
  end

  # Get the update
  def update
    $redis.get("Update:#{@id}")
  end
end
