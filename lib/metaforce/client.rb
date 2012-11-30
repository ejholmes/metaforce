module Metaforce
  class Client
    class << self
      def endpoint(key)
        define_method :endpoint do; @options[key] end
      end

      def wsdl(wsdl)
        define_method :wsdl do; wsdl end
      end
    end

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
        if e.message =~ /INVALID_SESSION_ID/ && authentication_handler && authentication_handler.respond_to?(:call)
          authenticate!
          client.request(*args, &block)
        else
          raise e
        end
      end
    end

    def authenticate!
      authentication_handler.call(self, @options)
    end

    def authentication_handler
      Metaforce.configuration.authentication_handler
    end

    def soap_headers
      { 'ins0:SessionHeader' => { 'ins0:sessionId' => session_id } }
    end

    def session_id
      @options[:session_id]
    end
  end
end
