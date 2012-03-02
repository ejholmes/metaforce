require "spec_helper"

describe Metaforce::Transaction do

  before(:each) do
    savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
    Metaforce::Metadata::Client.any_instance.stubs(:create_deploy_file).returns('')
  end

  let(:client) do
    Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
  end

  describe ".done?" do

    it "allows you to check if the transaction has completed" do
      savon.expects(:deploy).with(:zip_file => '', :deploy_options => {}).returns(:in_progress)
      savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
      deployment = client.deploy(File.expand_path('../../../fixtures/sample', __FILE__))
      deployment.done?.should eq(true)
    end

    it "doesn't send a request if it has already completed" do
      savon.expects(:deploy).with(:zip_file => '', :deploy_options => {}).returns(:in_progress)
      savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
      deployment = client.deploy(File.expand_path('../../../fixtures/sample', __FILE__))
      deployment.done?.should eq(true)
      expect { deployment.done?.should eq(true) }.to_not raise_error
    end

  end

  describe ".status" do

    it "returns the status" do
      savon.expects(:deploy).with(:zip_file => '', :deploy_options => {}).returns(:in_progress)
      savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
      deployment = client.deploy(File.expand_path('../../../fixtures/sample', __FILE__))
      savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
      deployment.status.should be_a(Hash)
    end
    
  end

  describe ".result" do

    it "allows you to check the transaction result" do
      savon.expects(:deploy).with(:zip_file => '', :deploy_options => {}).returns(:in_progress)
      savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
      deployment = client.deploy(File.expand_path('../../../fixtures/sample', __FILE__))
      deployment.done?.should eq(true)
      savon.expects(:check_deploy_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
      deployment.result.should be_a(Hash)
    end

    it "doesn't send a request if it has already retrieved the result" do
      savon.expects(:deploy).with(:zip_file => '', :deploy_options => {}).returns(:in_progress)
      savon.expects(:check_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
      deployment = client.deploy(File.expand_path('../../../fixtures/sample', __FILE__))
      deployment.done?.should eq(true)
      savon.expects(:check_deploy_status).with(:ids => [ "04sU0000000WNWoIAO" ]).returns(:done)
      deployment.result.should be_a(Hash)
      expect { deployment.result }.to_not raise_error
    end

  end

end
