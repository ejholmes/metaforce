require "spec_helper"

describe Metaforce::Metadata::Client do
  before(:each) do
    savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
  end
  describe ".list" do
    context "when given valid information" do
      it "returns an array" do
        client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
        savon.expects(:list_metadata).with(:queries => [ :type => "ApexClass"]).returns(:objects)
        client.list(:type => "ApexClass").class.should eq(Array)
      end
    end
  end
  describe ".describe" do
    context "when given valid information" do
      it "returns a hash" do
        client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
        savon.expects(:describe_metadata).returns(:success)
        client.describe.class.should eq(Hash)
      end
    end
  end
  describe ".status" do
    context "when given an invalid id" do
      it "raises an" do
        client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
        expect { client.status("badId") }.to raise_error
      end
    end
    context "when given an id of a result that has completed" do
      it "the :done key contains true" do
        client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
        savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
        client.status("04sU0000000WNWoIAO")[:done].should eq(true)
      end
    end
    context "when given an id of a result that has not completed" do
      it "the :done key contains false" do
        client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
        savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAo" ]).returns(:not_done)
        client.status("04sU0000000WNWoIAo")[:done].should eq(false)
      end
    end
  end
  describe ".is_done?" do
    context "when given an id of a result that has completed" do
      it "returns true" do
        client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
        savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
        client.is_done?("04sU0000000WNWoIAO").should eq(true)
      end
    end
    context "when given an id of a result that has not completed" do
      it "returns false" do
        client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
        savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAo" ]).returns(:not_done)
        client.is_done?("04sU0000000WNWoIAo").should eq(false)
      end
    end
  end
  context "deploy" do
    # it "deploys" do
      # client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
      # savon.expects(:deploy).with(:zip_file => "base64").returns(:in_progress)
    # end
  end
end
