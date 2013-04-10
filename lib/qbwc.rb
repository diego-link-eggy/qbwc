$:.unshift File.dirname(File.expand_path(__FILE__))
require 'qbwc/version'
require 'quickbooks'

module QBWC

  # Minimum quickbooks version required for use in qbxml requests
  mattr_accessor :min_version
  @@min_version = 3.0
 
  mattr_reader :on_error
  @@on_error = 'stopOnError'

class << self

  def create_request(qbxml) 
    QBWC::Request.new(qbxml)
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
require 'qbwc/soap_wrapper/default'
require 'qbwc/soap_wrapper/defaultMappingRegistry'
require 'qbwc/soap_wrapper'
require 'qbwc/session'
require 'qbwc/request'
