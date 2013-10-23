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
        request :send_email do |soap|
          soap.body = {
            :messages => options,
            :attributes! => { 'ins0:messages' => { 'xsi:type' => 'ins0:SingleEmailMessage' } }
          }
        end
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
        request :describe_layout do |soap|
          soap.body = { 'sObjectType' => sobject }
          soap.body.merge!('recordTypeID' => record_type_id) if record_type_id
        end
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

      def inspect
        "#<#{self.class} @options=#{@options.inspect}>"
      end

      # Public: Retrieves the current system timestamp 
      #         (Coordinated Universal Time (UTC) time zone) from the API.
      # 
      # Example: client.services.send(:get_server_timestamp)
      def get_server_timestamp
        request :get_server_timestamp
      end

      # Public: Retrieves personal information for the user associated 
      #         with the current session.
      # Example: client.services.send(:get_user_info)
      def get_user_info
        request :get_user_info
      end
    end
  end
end
