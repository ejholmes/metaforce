module Metaforce
  module Services
    class Client < Metaforce::Client
      # Returns the layout metadata for the sobject.
      # If a +record_type_id+ is passed in, it will only return the layout for
      # that record type.
      def describe_layout(sobject, record_type_id=nil)
        body = {
          'sObjectType' => sobject
        }
        body['recordTypeID'] = record_type_id if record_type_id
        response = request(:describe_layout) do |soap|
          soap.header = soap_headers
          soap.body = body
        end
        Hashie::Mash.new(response.body).describe_layout_response.result
      end

      # Get active picklists for a record type.
      def picklist_values(sobject, record_type_id, field)
        picklists = describe_layout(sobject, record_type_id).record_type_mappings.picklists_for_record_type
        picklists.select { |p| p.picklist_name == field }.first.picklist_values
          .select { |p| p.active }.collect { |p| [ p.label, p.value ] }
      end

    private

      def client
        @client ||= Savon.client(Metaforce.configuration.partner_wsdl) do |wsdl|
          wsdl.endpoint = services_url
        end.tap do |client|
          client.config.soap_header = soap_headers
          client.http.auth.ssl.verify_mode = :none
        end
      end

      def session_id
        @options[:session_id]
      end

      def services_url
        @options[:services_url]
      end
    end
  end
end
