require File.expand_path('../../../spec_helper', __FILE__)
require "metaforce"

describe Metaforce::Services::Client do
  context "login" do
    it "raises an error with invalid credentials" do
      savon.expects(:login).with(:username => 'invalid', :password => 'password').returns(:failure)
      expect { Metaforce::Services::Client.new(:username => 'invalid', :password => 'password') }.to raise_error
    end
    it "logs a user in and gets the session" do
      savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
      session = Metaforce::Services::Client.new(:username => 'valid', :password => 'password').session
      session.should eq({ :session_id => "00DU0000000Ilbh!AQoAQHVcube9Z6CRlbR9Eg8ZxpJlrJ6X8QDbnokfyVZItFKzJsLHIRGiqhzJkYsNYRkd3UVA9.s82sbjEbZGUqP3mG6TP_P8",
                          :metadata_server_url => "https://na12-api.salesforce.com/services/Soap/m/23.0/00DU0000000Albh" })
    end
  end
end
