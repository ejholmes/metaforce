require File.expand_path('../../../spec_helper', __FILE__)
require "metaforce/api/services"

describe Metaforce::Services::Client do
  Savon.log = false
  context "login" do
    it "raises an error with invalid credentials" do
      services = Metaforce::Services::Client.new
      expect { services.login('user', 'password', 'token') }.to raise_error
    end
    it "logs a user in" do
      services = Metaforce::Services::Client.new
    end
  end
end
