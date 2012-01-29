require "spec_helper"
require "metaforce/dsl"
include Metaforce::DSL::Metadata

describe Metaforce::DSL::Metadata do

  let(:manifest) do
    Metaforce::Manifest.new(File.open(File.expand_path('../../fixtures/sample/src/package.xml', __FILE__)).read)
  end

  let(:valid_credentials) do
    { :username => 'valid', :password => 'password' }
  end

  describe ".login" do

    before(:each) do
      savon.expects(:login).with(valid_credentials).returns(:success)
    end

    it "logs the user in" do
      expect { login valid_credentials }.to_not raise_error
    end

  end

  describe ".deploy" do

    before(:each) do
      Metaforce::Metadata::Client.any_instance.stubs(:create_deploy_file).returns('')
      savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
      savon.expects(:deploy).with(:zip_file => '', :deploy_options => {}).returns(:in_progress)
      savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
      savon.expects(:check_deploy_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
    end

    context "when given a directory" do

      it "deploys the directory" do
        login valid_credentials
        expect {
          deploy File.expand_path('../../../fixtures/sample', __FILE__) do |result|
            result.should be_a(Hash)
          end
        }.to_not raise_error
      end

    end

  end

  describe ".retrieve" do
    before(:each) do
      savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
      savon.expects(:retrieve).with(:retrieve_request => { :api_version => Metaforce.configuration.api_version, :single_package => true, :unpackaged => { :types => manifest.to_package } }).returns(:in_progress)
      savon.expects(:check_status).with(:ids => ['04sU0000000WkdIIAS']).returns(:done)
      savon.expects(:check_retrieve_status).with(:ids => ['04sU0000000WkdIIAS']).returns(:success)
    end

    context "when given a manifest file" do

      it "retrieves the components" do
        login valid_credentials
        expect {
          retrieve manifest do |result|
            result.should be_a(Hash)
          end
        }.to_not raise_error
      end

    end

  end
end
