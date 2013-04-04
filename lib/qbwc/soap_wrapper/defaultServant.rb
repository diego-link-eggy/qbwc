 
class QBWC::QBWebConnectorSvcSoap

  def initialize(client_id, company_file_path) 
    @client_id = client_id
    @company_file_path = company_file_path
  end

  def serverVersion(parameters)
    QBWC::ServerVersionResponse.new(nil)
  end

  def clientVersion(parameters)
    QBWC::ClientVersionResponse.new(nil)
  end
  
  def authenticate(parameters) # Create new session here
    QBWC.sessions[client_id] = QBWC::Session.new client_id
    QBWC::AuthenticateResponse.new([@client_id, @company_file_path])
  end

  def sendRequestXML(parameters)
    next_request = QBWC.sessions[@client_id].next!
    wrapped_request = %Q( <?qbxml version="#{QBWC.min_version}"?> ) + (next_request ? next_request.request : '')
    QBWC::SendRequestXMLResponse.new(wrapped_request)
  end

  def receiveResponseXML(response)
    finished = QBWC.sessions[@client_id].process_response(response.response)
    QBWC::ReceiveResponseXMLResponse.new(finished ? 100 : 0)
  end

  def connectionError(parameters)
    raise NotImplementedError.new
  end

  def getLastError(parameters)
    QBWC::GetLastErrorResponse.new(nil)
  end

  def closeConnection(parameters)
    QBWC.sessions.delete @client_id
    QBWC::CloseConnectionResponse.new('OK')
  end

end
