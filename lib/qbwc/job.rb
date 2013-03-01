class QBWC::Job

  attr_reader :name, :response_proc, :requests

  def initialize(name, &block)
    @name = name
    @enabled = true
    @requests = block
  end

  def enable
    @enabled = true
  end

  def disable
    @enabled = false
  end

  def enabled?
    @enabled
  end

  def next
    @request_gen.alive? ? @request_gen.resume : nil
  end

  def generate_requests(client_id)
    request_queue = @requests.call(client_id)
    @request_gen = Fiber.new { request_queue.each { |r| Fiber.yield r }; nil }
  end

end
