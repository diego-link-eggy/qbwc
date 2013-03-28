 
class QBWC::QBWebConnectorSvcSoap

  def initialize(client_id)
    @client_id = client_id
  end

  def serverVersion(parameters)
    QBWC::ServerVersionResponse.new(nil)
  end

  def clientVersion(parameters)
    QBWC::ClientVersionResponse.new(nil)
  end
  
  def authenticate(parameters)                              
    QBWC::AuthenticateResponse.new([QBWC.username, QBWC.company_file_path]) #path to company file
  end

  def sendRequestXML(parameters)
    qbwc_session = QBWC.session(@client_id)
    next_request = qbwc_session.next!
    QBWC::SendRequestXMLResponse.new( next_request ? wrap_in_version(next_request.request) : '') 
  end

  def receiveResponseXML(response)
    qbwc_session = QBWC.session(@client_id)
    finished = qbwc_session.process_response(response.response)
    QBWC::ReceiveResponseXMLResponse.new(finished ? 100 : 0)
  end

  def connectionError(parameters)
    #p [parameters]
    raise NotImplementedError.new
  end

  def getLastError(parameters)
    #p [parameters]
    QBWC::GetLastErrorResponse.new(nil)
  end

  def closeConnection(parameters)
    #p [parameters]
    qbwc_session = QBWC.session(@client_id)
    if qbwc_session && qbwc_session.finished?
      qbwc_session.current_request.process_response unless qbwc_session.current_request.blank?
    end
    QBWC::CloseConnectionResponse.new('OK')
  end

private

  # wraps xml in version header
  def wrap_in_version(xml_rq)
    if QBWC.api == :qbpos
      %Q( <?qbposxml version="#{QBWC.min_version}"?> ) + xml_rq
    else
      %Q( <?qbxml version="#{QBWC.min_version}"?> ) + xml_rq
    end
  end

end
