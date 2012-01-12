require File.expand_path('../../../spec_helper', __FILE__)
require "metaforce/api/metadata"

describe Metaforce::Metadata::Client do
  context "list metadata" do
    it "lists metadata" do
      savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
      client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
      savon.expects(:list_metadata).with(:queries => [ :type => "ApexClass"]).returns(:objects)
      client.list(:type => "ApexClass").class.should eq(Array)
    end
  end
  context "describe metadata" do
    it "describes the organization" do
      savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
      client = Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
      savon.expects(:describe_metadata).returns(:success)
      client.describe.class.should eq(Hash)
    end
  end
end
