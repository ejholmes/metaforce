require File.expand_path('../../../spec_helper', __FILE__)
require "metaforce"

describe Metaforce::Services::Client do
  context "login" do
    it "raises an error with invalid credentials" do
      services = Metaforce::Services::Client.new
      savon.expects(:login).with(:username => 'invalid', :password => 'password').returns(:failure)
      expect { services.login('invalid', 'password') }.to raise_error
    end
    it "logs a user in" do
      services = Metaforce::Services::Client.new
      savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
      services.login('valid', 'password').should eq('00DU0000000Ilbh!AQoAQHVcube9Z6CRlbR9Eg8ZxpJlrJ6X8QDbnokfyVZItFKzJsLHIRGiqhzJkYsNYRkd3UVA9.s82sbjEbZGUqP3mG6TP_P8')
    end
  end
end
