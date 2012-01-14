require 'savon'

module Metaforce
  module Services
    class Client
      attr_reader :session

      def initialize(options={})
        @session = self.login(options[:username], options[:password], options[:security_token])
      end

      def login(username, password, security_token=nil)
        password = "#{password}#{security_token}" unless security_token.nil?
        client = Savon::Client.new File.expand_path("../../../../wsdl/#{Metaforce.configuration.api_version}/partner.xml", __FILE__)
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
