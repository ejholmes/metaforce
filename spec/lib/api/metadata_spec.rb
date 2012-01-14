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
    context "when given valid information" do

      it "returns an array" do
        savon.expects(:list_metadata).with(:queries => [ :type => "ApexClass"]).returns(:objects)
        client.list(:type => "ApexClass").should be_an(Array)
      end

    end
  end

  describe ".describe" do
    context "when given valid information" do

      it "returns a hash" do
        savon.expects(:describe_metadata).returns(:success)
        client.describe.should be_a(Hash)
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
  end

  describe ".is_done?" do
    context "when given an id of a result that has completed" do

      it "returns true" do
        savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
        client.is_done?("04sU0000000WNWoIAO").should eq(true)
      end

    end
    context "when given an id of a result that has not completed" do

      it "returns false" do
        savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAo" ]).returns(:not_done)
        client.is_done?("04sU0000000WNWoIAo").should eq(false)
      end

    end
  end

  describe ".deploy" do

    before(:each) do
      Metaforce::Metadata::Client.any_instance.stubs(:create_deploy_file).returns('')
    end
    
    context "when given a directory to deploy" do

      it "deploys the directory and returns the id of the result" do
        savon.expects(:deploy).with(:zip_file => '', :deploy_options => {}).returns(:in_progress)
        id = client.deploy(File.expand_path('../../../fixtures/sample/src', __FILE__))
        id.should eq("04sU0000000WNWoIAO")
      end

    end

    # context "when given a file" do

      # it "deploys the file and returns the id of the result" do
        # path = Tempfile.new('zipfile').tap { |f| f.write('h'); f.close }.path
        # savon.expects(:deploy).with(:zip_file => "aA==\n", :deploy_options => {}).returns(:in_progress)
        # id = client.deploy(File.open(path))
        # id.should eq("04sU0000000WNWoIAO")
      # end

    # end

    it "allows deploy options to be configured via a hash" do
      savon.expects(:deploy).with(:zip_file => '', :deploy_options => { :run_all_tests => true }).returns(:in_progress)
      expect {
        client.deploy('', { :run_all_tests => true })
      }.to_not raise_error
    end

    it "allows deploy options to be configured via a block" do
      savon.expects(:deploy).with(:zip_file => '', :deploy_options => { :run_all_tests => true }).returns(:in_progress)
      expect {
        client.deploy('') do |options|
          options.run_all_tests = true
        end
      }.to_not raise_error
    end
    
  end
end
