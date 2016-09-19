class Stream
  def initialize(&callback)
    @callback = callback
    @closed = false
  end

  def close
    @closed = true
  end

  def each(&front)
    @front = front
    @callback.call(self)
    close
  end

  def <<(data)
    @front.call(data.to_s)
    self
  end

  def closed?
    @closed
  end
end
