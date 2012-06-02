require "spec_helper"

describe Metaforce do
  describe ".configuration" do

    it "sets the default api version to 23.0" do
      Metaforce.configuration.api_version.should eq("23.0")
    end

    it "allows you to configure the api version" do
      Metaforce.configuration.api_version = "21.0"
      Metaforce.configuration.api_version.should eq("21.0")
    end

  end

  describe ".configure" do

    it "allows you to configure the api version" do
      Metaforce.configure do |config|
        config.api_version = "21.0"
      end
      Metaforce.configuration.api_version.should eq("21.0")
    end

    context "credentials" do

      it "allows you to set the credentials via the configure block" do
        Metaforce.configure do |config|
          config.api_version = "23.0"
          config.username = "valid"
          config.password = "password"
        end
        savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
        session = Metaforce::Services::Client.new.session
        session.should eq({ :session_id => "00DU0000000Ilbh!AQoAQHVcube9Z6CRlbR9Eg8ZxpJlrJ6X8QDbnokfyVZItFKzJsLHIRGiqhzJkYsNYRkd3UVA9.s82sbjEbZGUqP3mG6TP_P8",
                            :metadata_server_url => "https://na12-api.salesforce.com/services/Soap/m/23.0/00DU0000000Albh",
                            :services_url => "https://na12-api.salesforce.com/services/Soap/u/23.0/00DU0000000Ilbh" })
      end

      it "allows you to set the credentials via the configure block" do
        Metaforce.configure do |config|
          config.api_version = "23.0"
          config.username = "valid"
          config.password = "password"
        end
        savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
        expect { Metaforce::Metadata::Client.new }.to_not raise_error
      end

    end

  end
end
