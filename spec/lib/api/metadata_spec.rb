require "spec_helper"

describe Metaforce::Metadata::Client do
  before(:each) do
    savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
  end
  context "list metadata" do
    it "lists metadata" do
      client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
      savon.expects(:list_metadata).with(:queries => [ :type => "ApexClass"]).returns(:objects)
      client.list(:type => "ApexClass").class.should eq(Array)
    end
  end
  context "describe metadata" do
    it "describes the organization" do
      client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
      savon.expects(:describe_metadata).returns(:success)
      client.describe.class.should eq(Hash)
    end
  end
  context "check status" do
    it "raises an error with a bad id" do
      client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
      expect { client.status("badId") }.to raise_error
    end
    it "returns an async result when done" do
      client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
      savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
      client.status("04sU0000000WNWoIAO")[:done].should eq(true)
    end
    it "returns an async result when not done" do
      client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
      savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAo" ]).returns(:not_done)
      client.status("04sU0000000WNWoIAo")[:done].should eq(false)
    end
    it "returns done" do
      client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
      savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
      client.is_done?("04sU0000000WNWoIAO").should eq(true)
    end
    it "returns not done" do
      client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
      savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAo" ]).returns(:not_done)
      client.is_done?("04sU0000000WNWoIAo").should eq(false)
    end
  end
  context "deploy" do
    # it "deploys" do
      # client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
      # savon.expects(:deploy).with(:zip_file => "base64").returns(:in_progress)
    # end
  end
end
