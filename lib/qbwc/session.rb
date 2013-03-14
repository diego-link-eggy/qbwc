class QBWC::Session
  include Enumerable

  attr_reader :current_job, :current_request, :saved_requests, :finished
  attr_reader :qbwc_iterator_queue, :qbwc_iterating

  def initialize(client_id)
    @current_request = nil
    @requests = []
    QBWC.jobs.values.each do |job|
      @requests.push(*job.generate_requests(client_id))
    end
    @finished = @requests.blank?
  end

  def finished?
    finished
  end

  def next!
    @current_request = @requests.shift
  end

  def process_response(qbxml_response)
    @current_request.response = QBWC.parser.qbxml_to_hash(qbxml_response)
    parse_response_header(@current_request.response)
    @current_request.process_response
    @finished = @requests.blank?
  end

  private

  def parse_response_header(response)
    return unless response['xml_attributes']

    status_code, status_severity, status_message, iterator_remaining_count, iterator_id = \
      response['xml_attributes'].values_at('statusCode', 'statusSeverity', 'statusMessage', 
                                               'iteratorRemainingCount', 'iteratorID') 

    if status_severity == 'Error' || status_code.to_i > 1 || response.keys.size <= 1
      @current_request.error = "QBWC ERROR: #{status_code} - #{status_message}"
      puts @current_request.error
    else
      if iterator_remaining_count.to_i > 0
        continue_request = @current_request.to_hash
        continue_request.delete('xml_attributes')
        continue_request.values.first['xml_attributes'] = {'iterator' => 'Continue', 'iteratorID' => iterator_id}
        @requests.unshift(QBWC::Request.new(continue_request, @current_request.response_proc))
      end
    end
  end
end
