require "metaforce/api/metadata"

describe Metaforce::Manifest do
  it "logs a user in" do
    metadata = Metaforce::Metadata.new
    metadata.login('user', 'password', 'token')
  end
end
