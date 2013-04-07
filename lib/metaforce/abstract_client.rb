module Metaforce
  class AbstractClient
    class << self
      # Internal
      def endpoint(key)
        define_method :endpoint do; @options[key] end
      end

      # Internal
      def wsdl(wsdl)
        define_method :wsdl do; wsdl end
      end
    end

    # Public: Initialize a new client.
    #
    # options - A hash of options, which should have a :session_id key
    def initialize(options={})
      raise 'Please specify a hash of options' unless options.is_a?(Hash)
      @options = options
    end

  private

    # Internal: The Savon client to send SOAP requests with.
    def client
      @client ||= Savon.client(wsdl) do |wsdl|
        wsdl.endpoint = endpoint
      end.tap do |client|
        client.config.soap_header = soap_headers
        client.http.auth.ssl.verify_mode = :none
      end
    end

    # Internal: Performs a SOAP request. If the session is invalid, it will
    # attempt to reauthenticate by called the reauthentication handler if
    # present.
    def request(*args, &block)
      authenticate! unless session_id
      retries = authentication_retries
      begin
        perform_request(*args, &block)
      rescue Savon::SOAP::Fault => e
        if e.message =~ /INVALID_SESSION_ID/ && authentication_handler && retries > 0
          authenticate!
          retries -= 1
          retry
        end
        raise
      end
    end

    def perform_request(*args, &block)
      response = client.request(*args, &block)
      Hashie::Mash.new(response.body)[:"#{args[0]}_response"].result
    end

    # Internal Calls the authentication handler, which should set @options to a new
    # hash.
    def authenticate!
      options = authentication_handler.call(self, @options)
      @options.merge!(options)
      client.config.soap_header = soap_headers
    end

    # A proc object that gets called when the client needs to reauthenticate.
    def authentication_handler
      Metaforce.configuration.authentication_handler
    end

    def authentication_retries
      3
    end

    # Internal: Soap headers to set for authenticate.
    def soap_headers
      { 'ins0:SessionHeader' => { 'ins0:sessionId' => session_id } }
    end

    # Internal: The session id, which can be obtained by calling
    # Metaforce.login or through OAuth.
    def session_id
      @options[:session_id]
    end
  end
end
