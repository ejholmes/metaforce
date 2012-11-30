module Metaforce
  module Services
    class Client < Metaforce::Client
      endpoint :services_url
      wsdl Metaforce.configuration.partner_wsdl

      # Returns the layout metadata for the sobject.
      # If a +record_type_id+ is passed in, it will only return the layout for
      # that record type.
      def describe_layout(sobject, record_type_id=nil)
        body = {
          'sObjectType' => sobject
        }
        body['recordTypeID'] = record_type_id if record_type_id
        response = request(:describe_layout) do |soap|
          soap.body = body
        end
        Hashie::Mash.new(response.body).describe_layout_response.result
      end

      # Get active picklists for a record type.
      # TODO: Some serious smell here, abstract this into a Layout class?
      def picklist_values(sobject, record_type_id, field)
        picklists = describe_layout(sobject, record_type_id).record_type_mappings.picklists_for_record_type
        picklists.select { |p| p.picklist_name == field }.first.picklist_values
          .select { |p| p.active }.collect { |p| [ p.label, p.value ] }
      end
    end
  end
end
