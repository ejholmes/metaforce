require 'savon'

module Metaforce
  module Services
    class Client
      # Contains the session_id and metadata_server_url
      attr_reader :session

      # Initializes a new instance of Client and logs in. _options_ should be a
      # hash containing the username, password and security token. If options
      # is nil, it will get the username, password and security token from the
      # configuration.
      def initialize(options=nil)
        @options = options
        # Convert string keys to hashes
        @options.dup.each { |key, value| options[key.to_sym] = value } if options.is_a?(Hash)

        @options = {
          :username => Metaforce.configuration.username,
          :password => Metaforce.configuration.password,
          :security_token => Metaforce.configuration.security_token
        } if @options.nil?
        @session = self.login(@options[:username], @options[:password], @options[:security_token])

        @client = Savon::Client.new File.expand_path("../../../../wsdl/#{Metaforce.configuration.api_version}/partner.xml", __FILE__) do |wsdl|
          wsdl.endpoint = @session[:services_url]
        end
        @client.http.auth.ssl.verify_mode = :none
      end

      # Performs a login and retrurns the session
      def login(username, password, security_token=nil)
        password = "#{password}#{security_token}" unless security_token.nil?
        client = Savon::Client.new File.expand_path("../../../../wsdl/#{Metaforce.configuration.api_version}/partner.xml", __FILE__) do |wsdl|
          wsdl.endpoint = wsdl.endpoint.to_s.sub(/login/, 'test') if Metaforce.configuration.test
          Metaforce.log("Logging in via #{wsdl.endpoint.to_s}")
        end
        client.http.auth.ssl.verify_mode = :none

        response = client.request(:login) do
          soap.body = {
            :username => username,
            :password => password
          }
        end
        { :session_id => response.body[:login_response][:result][:session_id],
          :metadata_server_url =>  response.body[:login_response][:result][:metadata_server_url],
          :services_url => response.body[:login_response][:result][:server_url] }
      end

      # Returns the layout metadata for the sobject.
      # If a +record_type_id+ is passed in, it will only return the layout for
      # that record type.
      #
      # This method is really useful finding out picklist values that are
      # available for a certain record type
      #
      # == Examples
      #
      #   @picklists_for_record_type = client.describe_layout('Account', '0123000000100Rn')[:record_type_mappings][:picklists_for_record_type]
      #
      #   def picklist_values_for(field)
      #     picklist_values = @picklists_for_record_type.select { |f| f[:picklist_name] == field }.first[:picklist_values]
      #     picklist_values.select { |p| p[:active] }.collect { |p| [ p[:label], p[:value] ] }
      #   end
      #
      #   picklist_values_for('some_field__c')
      #   # => [ ['label1', 'value1'], ['label2', 'value2'] ] 
      def describe_layout(sobject, record_type_id=nil)
        body = {
          'sObjectType' => sobject
        }
        body['recordTypeID'] = record_type_id if record_type_id
        response = request(:describe_layout) do |soap|
          soap.header = header
          soap.body = body
        end
        response.body[:describe_layout_response][:result]
      end

    private

      def header
        {
          "ins0:SessionHeader" => {
            "ins0:sessionId" => @session[:session_id]
          }
        }
      end

      def request(*args, &block)
        begin
          @client.request(*args, &block)
        rescue Savon::SOAP::Fault => e
          @session = self.login(@options[:username], @options[:password], @options[:security_token])
          @client.request(*args, &block)
        end
      end

    end
  end
end
