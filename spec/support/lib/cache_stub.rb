class CacheStub
  def initialize
    @counter = 0
  end
  def increment(key, seconds)
    @counter += 1
  end
  def expire(key, time)
  end
  def get(key)
    @counter
  end
end