require 'savon'

module Metaforce
  class Metadata
    def login(username, password, security_token=nil)
      Savon.log = false
      password = "#{password}#{security_token}" unless security_token.nil?
      client = Savon::Client.new File.expand_path('../../../../wsdl/23.0/partner.xml', __FILE__)
      response = client.request(:login) do
        soap.body = {
          :username => username,
          :password => password
        }
      end
      @session_id = response.body[:login_response][:result][:session_id]
      self
    end
  end
end
