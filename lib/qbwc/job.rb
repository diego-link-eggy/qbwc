class QBWC::Job

  attr_reader :name, :response_proc, :requests

  def initialize(name, &block)
    @name = name
    @requests = block
  end

  def generate_requests(client_id)
    return @requests.call(client_id)
  end

end