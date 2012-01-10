require "metaforce/api/services"
require "mocha"

describe Metaforce::Services::Client do
  it "logs a user in" do
    services = Metaforce::Services::Client.new
    services.expects(:login).with('user', 'password', 'token').returns('laksdlk')
    services.login('user', 'password', 'token').should eq('laksdlk')
  end
end
