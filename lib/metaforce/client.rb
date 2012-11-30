module Metaforce
  class Client
    def initialize(options={})
      raise 'Please specify a hash of options' unless options.is_a?(Hash)
      @options = options
    end

  private

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

    def session_id
      raise 'not implemented.'
    end

    # The underlying savon client for dealing with SOAP.
    def client
      raise 'not implemented.'
    end
  end
end
