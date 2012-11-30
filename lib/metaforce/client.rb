module Metaforce
  class Client
    def initialize(options={})
      raise 'Please specify a hash of options' unless options.is_a?(Hash)
      @options = options
    end

  private

    def client
      @client ||= Savon.client(wsdl) do |wsdl|
        wsdl.endpoint = endpoint
      end.tap do |client|
        client.config.soap_header = soap_headers
        client.http.auth.ssl.verify_mode = :none
      end
    end

    # Performs an actual request.
    def request(*args, &block)
      begin
        client.request(*args, &block)
      rescue Savon::SOAP::Fault => e
        if e.message =~ /INVALID_SESSION_ID/
          # Need to reauthenticate
          client.request(*args, &block)
        else
          raise e
        end
      end
    end

    def soap_headers
      { 'ins0:SessionHeader' => { 'ins0:sessionId' => session_id } }
    end

    %w[endpoint wsdl session_id].each do |m|
      define_method m.to_sym do; raise 'not implemented.' end
    end
  end
end
