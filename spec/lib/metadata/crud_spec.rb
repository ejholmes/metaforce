require "spec_helper"

describe Metaforce::Metadata::Client do

  before(:each) do
    savon.expects(:login).with(:username => 'valid', :password => 'password').returns(:success)
  end

  let(:client) do
    Metaforce::Metadata::Client.new(:username => 'valid', :password => 'password')
  end
  
  describe ".create" do
    it "returns a transaction" do
      savon.expects(:create).with(:metadata => [{:api_version => '23.0', :description => '', :label => 'test', :content => '', :full_name => 'component'}], :attributes! => {'ins0:metadata' => {'xsi:type' => 'wsdl:ApexComponent'}}).returns(:in_progress)
      savon.expects(:check_status).with(:ids => ['04sU0000000WNWoIAO']).returns(:done);
      response = client.create(:apex_component, :full_name => 'component', :label => 'test', :content => '')
      response.should be_a(Metaforce::Transaction)
    end

    it "base64 encodes any content" do
      savon.expects(:create).with(:metadata => [{:api_version => '23.0', :description => '', :full_name => 'component', :label => 'test', :content => "dGVzdA==\n"}], :attributes! => {'ins0:metadata' => {'xsi:type' => 'wsdl:ApexComponent'}}).returns(:in_progress)
      savon.expects(:check_status).with(:ids => ['04sU0000000WNWoIAO']).returns(:done);
      response = client.create(:apex_component, :full_name => 'component', :label => 'test', :content => 'test')
    end
  end

  describe ".delete" do
    it "returns a transaction" do
      savon.expects(:delete).with(:metadata => [{:full_name => 'component'}], :attributes! => {'ins0:metadata' => {'xsi:type' => 'wsdl:ApexComponent'}}).returns(:in_progress)
      savon.expects(:check_status).with(:ids => ['04sU0000000WNWoIAO']).returns(:done);
      response = client.delete(:apex_component, :full_name => 'component')
      response.should be_a(Metaforce::Transaction)
    end
  end

  describe ".update" do
    it "returns a transaction" do
      savon.expects(:update).with(:metadata => {:current_name => 'old_component', :metadata => [{:api_version => '23.0', :description => '', :label => 'test', :content => '', :full_name => 'component'}], :attributes! => {:metadata => {'xsi:type' => 'wsdl:ApexComponent'}}}).returns(:in_progress)
      savon.expects(:check_status).with(:ids => ['04sU0000000WNWoIAO']).returns(:done);
      response = client.update(:apex_component, 'old_component', :full_name => 'component', :label => 'test', :content => '')
      response.should be_a(Metaforce::Transaction)
    end
  end
end
