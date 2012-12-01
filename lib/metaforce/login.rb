module Metaforce
  class Login
    def initialize(username, password, security_token=nil)
      @username, @password, @security_token = username, password, security_token
    end

    # Public: Perform the login request.
    #
    # Returns a hash with the session id and server urls.
    def login
      response = client.request(:login) do
        soap.body = {
          :username => username,
          :password => password
        }
      end
      { :session_id => response.body[:login_response][:result][:session_id],
        :metadata_server_url => response.body[:login_response][:result][:metadata_server_url],
        :services_url => response.body[:login_response][:result][:server_url] }
    end

  private

    # Internal: Savon client.
    def client
      @client ||= Savon.client(Metaforce.configuration.partner_wsdl) do |wsdl|
        wsdl.endpoint = Metaforce.configuration.endpoint
      end.tap { |client| client.http.auth.ssl.verify_mode = :none }
    end

    # Internal: Usernamed passed in from options.
    def username
      @username
    end

    # Internal: Password + Security Token combined.
    def password
      [@password, @security_token].join('')
    end
  end
end
