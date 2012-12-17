module Metaforce
  module Services
    class Client < Metaforce::AbstractClient
      endpoint :server_url
      wsdl Metaforce.configuration.partner_wsdl

      # Public: Sends an email using Salesforce.
      #
      # options - Hash of email options (http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_sendemail.htm)
      #
      # Examples
      #
      #   client.send_email(
      #     to_addresses: ['foo@bar.com'],
      #     subject: 'Hello World',
      #     plain_text_body: 'Hello World'
      #   )
      #
      # Returns the result.
      def send_email(options={})
        response = request(:send_email) do |soap|
          soap.body = {
            :messages => options,
            :attributes! => { 'ins0:messages' => { 'xsi:type' => 'ins0:SingleEmailMessage' } }
          }
        end
        Hashie::Mash.new(response.body).send_email_response.result
      end

      # Public: Retrieves layout information for the specified sobject.
      #
      # sobject        - String name of the sobject.
      # record_type_id - String id of a record type to filter on.
      #
      # Examples
      #
      #  client.describe_layout('Account', '012000000000000AAA')
      #
      # Returns the layout metadata for the sobject.
      def describe_layout(sobject, record_type_id=nil)
        response = request(:describe_layout) do |soap|
          soap.body = { 'sObjectType' => sobject }
          soap.body.merge!('recordTypeID' => record_type_id) if record_type_id
        end
        Hashie::Mash.new(response.body).describe_layout_response.result
      end

      # Public: Get active picklists for a record type.
      #
      # sobject        - String name of the sobject.
      # record_type_id - String id of a record type to filter on.
      # field          - String name of the field to get picklist values for.
      #
      # Examples
      #
      #   client.picklist_values('Account', '012000000000000AAA', 'Some_Field__c')
      #   # => [['Label', 'Value']]
      #
      # Returns the picklist_values
      def picklist_values(sobject, record_type_id, field)
        describe_layout(sobject, record_type_id).record_type_mappings.picklists_for_record_type
          .select { |p| p.picklist_name == field }.first.picklist_values
          .select { |p| p.active }.collect { |p| [ p.label, p.value ] }
      end
    end
  end
end
