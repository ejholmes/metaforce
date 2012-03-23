require "spec_helper"
require "tempfile"

describe Metaforce::Metadata::Client do

  before(:each) do
    savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
  end

  let(:client) do
    Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
  end
  
  describe ".list" do

    it "returns an array" do
      savon.expects(:list_metadata).with(:queries => [ :type => "ApexClass"]).returns(:objects)
      client.list(:type => "ApexClass").should be_an(Array)
    end

    it "returns an empty array when no results are returned" do
      savon.expects(:list_metadata).with(:queries => [ :type => "ApexClass"]).returns(:no_result)
      client.list(:type => "ApexClass").should be_an(Array)
    end

    it "accepts a symbol" do
      savon.expects(:list_metadata).with(:queries => [ :type => "ApexClass"]).returns(:no_result)
      client.list(:apex_class).should be_an(Array)
    end

    it "accepts a string" do
      savon.expects(:list_metadata).with(:queries => [ :type => "ApexClass"]).returns(:no_result)
      client.list("ApexClass").should be_an(Array)
    end

  end

  it "should respond to dynamically defined list methods" do
    savon.expects(:list_metadata).with(:queries => [ :type => "ApexClass"]).returns(:no_result)
    client.list_apex_class.should be_an(Array)
  end

  describe ".describe" do
    context "when given valid information" do

      it "returns a hash" do
        savon.expects(:describe_metadata).returns(:success)
        client.describe.should be_a(Hash)
      end

      it "caches the response" do
        savon.expects(:describe_metadata).returns(:success)
        client.describe.should be_a(Hash)
        expect { client.describe }.to_not raise_error
      end

    end
  end

  describe ".metadata_objects" do
    it "returns the :metadata_objects key from the describe call" do
      savon.expects(:describe_metadata).returns(:success)
      client.metadata_objects.should be_a(Array)
    end
  end

  describe ".describe!" do
    context "when given valid information" do

      it "returns a hash" do
        savon.expects(:describe_metadata).returns(:success)
        client.describe!.should be_a(Hash)
      end

      it "doesn't cache the response" do
        savon.expects(:describe_metadata).returns(:success)
        client.describe!.should be_a(Hash)
        savon.expects(:describe_metadata).returns(:success)
        expect { client.describe! }.to_not raise_error
      end

    end
  end

  describe ".status" do
    context "when given an invalid id" do

      it "raises an" do
        expect { client.status("badId") }.to raise_error
      end

    end
    context "when given an id of a result that has completed" do

      it "returns a hash and the :done key contains true" do
        savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
        status = client.status("04sU0000000WNWoIAO")
        status.should be_a(Hash)
        status[:done].should eq(true)
      end

    end
    context "when given an id of a result that has not completed" do

      it "returns a hash and the :done key contains false" do
        savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAo" ]).returns(:not_done)
        status = client.status("04sU0000000WNWoIAo")
        status.should be_a(Hash)
        status[:done].should eq(false)
      end

    end
    context "when given and id of a deploy that has completed" do

      it "returns a hash" do
        savon.expects(:check_deploy_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
        status = client.status("04sU0000000WNWoIAO", :deploy)
        status.should be_a(Hash)
      end

    end
  end

  describe ".done?" do
    context "when given an id of a result that has completed" do

      it "returns true" do
        savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
        client.done?("04sU0000000WNWoIAO").should eq(true)
      end

    end
    context "when given an id of a result that has not completed" do

      it "returns false" do
        savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAo" ]).returns(:not_done)
        client.done?("04sU0000000WNWoIAo").should eq(false)
      end

    end
  end

  describe ".deploy" do

    before(:each) do
      Metaforce::Metadata::Client.any_instance.stubs(:create_deploy_file).returns('')
    end
    
    context "when given a directory to deploy" do

      it "deploys the directory and returns a transaction" do
        savon.expects(:deploy).with(:zip_file => '', :deploy_options => {}).returns(:in_progress)
        savon.expects(:check_status).with(:ids => ['04sU0000000WNWoIAO']).returns(:done);
        deployment = client.deploy(File.expand_path('../../../fixtures/sample', __FILE__))
        deployment.should be_a(Metaforce::Transaction)
        deployment.id.should eq("04sU0000000WNWoIAO")
      end

    end

    it "allows deploy options to be configured via a hash" do
      savon.expects(:deploy).with(:zip_file => '', :deploy_options => { :run_all_tests => true }).returns(:in_progress)
      savon.expects(:check_status).with(:ids => ['04sU0000000WNWoIAO']).returns(:done);
      expect {
        client.deploy('', :options => { :run_all_tests => true })
      }.to_not raise_error
    end

  end

  describe ".retrieve" do

    let(:manifest) do
      Metaforce::Manifest.new(File.open(File.expand_path('../../../fixtures/sample/src/package.xml', __FILE__)).read)
    end

    describe ".retrieve_unpackaged" do

      context "when given a manifest file" do
        before(:each) do
          savon.expects(:retrieve).with(:retrieve_request => { :api_version => Metaforce.configuration.api_version, :single_package => true, :unpackaged => { :types => manifest.to_package } }).returns(:in_progress)
          savon.expects(:check_status).with(:ids => ['04sU0000000WkdIIAS']).returns(:done)
          savon.expects(:check_retrieve_status).with(:ids => ['04sU0000000WkdIIAS']).returns(:success)
        end

        it "returns a valid retrieve result" do
          retrieval = client.retrieve_unpackaged(manifest)
          retrieval.done?
          result = retrieval.result
          result.should be_a(Hash)
        end

      end

      context "when given the path to a manifest file" do
        before(:each) do
          savon.expects(:retrieve).with(:retrieve_request => { :api_version => Metaforce.configuration.api_version, :single_package => true, :unpackaged => { :types => manifest.to_package } }).returns(:in_progress)
          savon.expects(:check_status).with(:ids => ['04sU0000000WkdIIAS']).returns(:done)
          savon.expects(:check_retrieve_status).with(:ids => ['04sU0000000WkdIIAS']).returns(:success)
        end

        it "returns a valid retrieve result" do
          retrieval = client.retrieve_unpackaged(File.expand_path('../../../fixtures/sample/src/package.xml', __FILE__))
          retrieval.done?
          result = retrieval.result
          result.should be_a(Hash)
        end

      end

      context "when given extra retrieve options" do
        before(:each) do
          savon.expects(:retrieve).with(:retrieve_request => { :api_version => Metaforce.configuration.api_version, :single_package => true, :unpackaged => { :types => manifest.to_package }, :extra => true }).returns(:in_progress)
          savon.expects(:check_status).with(:ids => ['04sU0000000WkdIIAS']).returns(:done);
        end

        it "merges the options" do
          expect {
            retrieval = client.retrieve_unpackaged(File.expand_path('../../../fixtures/sample/src/package.xml', __FILE__), :options => { :extra => true })
          }.to_not raise_error
        end

      end
    end

  end
end
