$:.unshift File.dirname(File.expand_path(__FILE__))
require 'qbwc/version'
require 'quickbooks'
require 'soap/rpc/standaloneServer'

module QBWC

  # Minimum quickbooks version required for use in qbxml requests
  mattr_accessor :min_version
  @@min_version = 3.0
 
  mattr_reader :on_error
  @@on_error = 'stopOnError'

class << self

  def route_request(servant, request)
    router = ::SOAP::RPC::Router.new('QBWebConnectorSvcSoap')
    router.mapping_registry = DefaultMappingRegistry::EncodedRegistry
    router.literal_mapping_registry = DefaultMappingRegistry::LiteralRegistry
    connection_data = ::SOAP::StreamHandler::ConnectionData.new
    servant.soap_actions.each do |action_name|
      router.add_document_operation(servant,
        "http://developer.intuit.com/#{action_name}",
        action_name,
        [ ["in", "parameters", ["::SOAP::SOAPElement", "http://developer.intuit.com/", "#{action_name}"]],
          ["out", "parameters", ["::SOAP::SOAPElement", "http://developer.intuit.com/", "#{action_name}Response"]] ],
        { :request_style =>  :document, :request_use =>  :literal,
          :response_style => :document, :response_use => :literal,
          :faults => {} }
      )
    end

    connection_data.receive_string = request.raw_post
    connection_data.receive_contenttype = request.content_type
    connection_data.soapaction = nil

    router.external_ces = nil 
    router.route(connection_data)
  end

  def on_error=(reaction)
    raise "Invalid error response #{reaction}" unless [:stop, :continue].include?(reaction)
    @@on_error = (reaction == :stop) ? "stopOnError" : "continueOnError"
  end

  # Allow configuration overrides
  def configure
    yield self
  end

end
  
end

#Todo Move this to Autolaod
require 'qbwc/default'
require 'qbwc/defaultMappingRegistry'
require 'qbwc/request'
