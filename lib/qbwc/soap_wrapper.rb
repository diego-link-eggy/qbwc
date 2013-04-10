require 'soap/rpc/standaloneServer'

class QBWC::SoapWrapper
  include QBWC

  def self.route_request(servant, request)
    @router = ::SOAP::RPC::Router.new('QBWebConnectorSvcSoap')
    @router.mapping_registry = DefaultMappingRegistry::EncodedRegistry
    @router.literal_mapping_registry = DefaultMappingRegistry::LiteralRegistry
    @conn_data = ::SOAP::StreamHandler::ConnectionData.new
    servant.soap_actions.each do |action_name|
      @router.add_document_operation(servant, 
      [
        "http://developer.intuit.com/#{action_name}",
        action_name,
        [ ["in", "parameters", ["::SOAP::SOAPElement", "http://developer.intuit.com/", "#{action_name}"]],
          ["out", "parameters", ["::SOAP::SOAPElement", "http://developer.intuit.com/", "#{action_name}Response"]] ],
        { :request_style =>  :document, :request_use =>  :literal,
          :response_style => :document, :response_use => :literal,
          :faults => {} }
      ]
    end

    @conn_data.receive_string = request.raw_post
    @conn_data.receive_contenttype = request.content_type
    @conn_data.soapaction = nil

    @router.external_ces = nil 
    res_data = @router.route(@conn_data) 
  end

end
