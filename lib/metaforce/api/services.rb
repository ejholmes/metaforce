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
        options = {
          :username => Metaforce.configuration.username,
          :password => Metaforce.configuration.password,
          :security_token => Metaforce.configuration.security_token
        } if options.nil?
        @session = self.login(options[:username], options[:password], options[:security_token])
      end

      # Performs a login and sets @session
      def login(username, password, security_token=nil)
        password = "#{password}#{security_token}" unless security_token.nil?
        client = Savon::Client.new File.expand_path("../../../../wsdl/#{Metaforce.configuration.api_version}/partner.xml", __FILE__) do |wsdl|
          wsdl.endpoint = wsdl.endpoint.to_s.sub(/login/, 'test') if Metaforce.configuration.test
        end
        client.http.auth.ssl.verify_mode = :none
        response = client.request(:login) do
          soap.body = {
            :username => username,
            :password => password
          }
        end
        { :session_id => response.body[:login_response][:result][:session_id],
          :metadata_server_url =>  response.body[:login_response][:result][:metadata_server_url] }
      end
    end
  end
end
