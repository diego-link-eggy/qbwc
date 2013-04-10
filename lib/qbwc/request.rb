class QBWC::Request

  attr_reader   :request
  attr_accessor :response, :error

  def initialize(request)
    #Handle Cases for a request passed in as a Hash or String
        @request = request


    #Allow strings of QBXML to be passed in directly. Request is stored as a hash
    if @request.is_a?(String)
      @request = QBWC.parser.qbxml_to_hash @request
  end

  def parse_response!(response)
    return unless response['xml_attributes']

    status_code, status_severity, status_message, iterator_remaining_count, iterator_id = \
      response['xml_attributes'].values_at('statusCode', 'statusSeverity', 'statusMessage', 
                                               'iteratorRemainingCount', 'iteratorID') 

    if status_severity == 'Error' || status_code.to_i > 1 || response.keys.size <= 1
      @error = "QBWC ERROR: #{status_code} - #{status_message}"
      puts @current_request.error
    else
      if iterator_remaining_count.to_i > 0
        @request.delete('xml_attributes')
        @request.values.first['xml_attributes'] = {'iterator' => 'Continue', 'iteratorID' => iterator_id}
      end
    end
  end

  def to_qbxml
    #Verify that the request is properly wrapped with qbxml_msg_rq and xml_attributes for on_error events
    unless @request.keys.include?(:qbxml_msgs_rq)
      wrapped_request = { :qbxml_msgs_rq => {:xml_attributes => { "onError"=> QBWC::on_error } } } 
      wrapped_request[:qbxml_msgs_rq] = wrapped_request[:qbxml_msgs_rq].merge(@request)
      @request = wrapped_request
    end

    #Wrap the 
    %Q( <?qbxml version="#{QBWC.min_version}"?> ) + QBWC.parser.hash_to_qbxml(request)
  end
end
