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
        # Convert string keys to hashes
        options.dup.each { |key, value| options[key.to_sym] = value } if options.is_a?(Hash)

        options = {
          :username => Metaforce.configuration.username,
          :password => Metaforce.configuration.password,
          :security_token => Metaforce.configuration.security_token
        } if options.nil?
        @session = self.login(options[:username], options[:password], options[:security_token])

        @client = Savon::Client.new File.expand_path("../../../../wsdl/#{Metaforce.configuration.api_version}/partner.xml", __FILE__) do |wsdl|
          wsdl.endpoint = @session[:services_url]
        end
        @client.http.auth.ssl.verify_mode = :none
        @header = {
            "ins0:SessionHeader" => {
              "ins0:sessionId" => @session[:session_id]
            }
        }
      end

      # Performs a login and sets @session
      def login(username, password, security_token=nil)
        password = "#{password}#{security_token}" unless security_token.nil?
        @client = Savon::Client.new File.expand_path("../../../../wsdl/#{Metaforce.configuration.api_version}/partner.xml", __FILE__) do |wsdl|
          wsdl.endpoint = wsdl.endpoint.to_s.sub(/login/, 'test') if Metaforce.configuration.test
          Metaforce.log("Logging in via #{wsdl.endpoint.to_s}")
        end
        @client.http.auth.ssl.verify_mode = :none

        response = @client.request(:login) do
          soap.body = {
            :username => username,
            :password => password
          }
        end
        { :session_id => response.body[:login_response][:result][:session_id],
          :metadata_server_url =>  response.body[:login_response][:result][:metadata_server_url],
          :services_url => response.body[:login_response][:result][:server_url] }
      end

      def describe_layout(sobject, record_type_id=nil)
        body = {
          'sObjectType' => sobject
        }
        body['recordTypeID'] = record_type_id if record_type_id
        response = @client.request(:describe_layout) do |soap|
          soap.header = @header
          soap.body = body
        end
        response.body[:describe_layout_response][:result]
      end
    end
  end
end
