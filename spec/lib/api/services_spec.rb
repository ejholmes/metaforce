require "metaforce/api/services"
require "mocha"

describe Metaforce::Services::Client do
  Savon.log = false
  context "login" do
    it "raises an error with invalid credentials" do
      services = Metaforce::Services::Client.new
      expect { services.login('user', 'password', 'token') }.to raise_error
    end
  end
end
