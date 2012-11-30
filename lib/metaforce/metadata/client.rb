module Metaforce
  module Metadata
    class Client < Metaforce::Client
      def list(*args)
        queries = { :type => args.map(&:to_s).map(&:camelize) }
        response = request(:list_metadata) do |soap|
          soap.body = { :queries => queries }
        end
        response.body[:list_metadata_response][:result]
      end

    private

      def client
        @client ||= Savon.client(Metaforce.configuration.metadata_wsdl) do |wsdl|
          wsdl.endpoint = metadata_server_url
        end.tap do |client|
          client.config.soap_header = soap_headers
          client.http.auth.ssl.verify_mode = :none
        end
      end

      def session_id
        @options[:session_id]
      end

      def metadata_server_url
        @options[:metadata_server_url]
      end
    end
  end
end
