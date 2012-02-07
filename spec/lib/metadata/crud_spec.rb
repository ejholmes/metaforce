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
      savon.expects(:create).with(:metadata => [{:full_name => 'component', :label => 'test'}], :attributes! => {'ins0:metadata' => {'xsi:type' => 'wsdl:ApexComponent'}}).returns(:in_progress)
      response = client.create(:apex_component, { :full_name => 'component', :label => 'test' })
      response.should be_a(Metaforce::Transaction)
    end

    it "base64 encodes any content" do
      savon.expects(:create).with(:metadata => [{:full_name => 'component', :label => 'test', :content => "dGVzdA==\n"}], :attributes! => {'ins0:metadata' => {'xsi:type' => 'wsdl:ApexComponent'}}).returns(:in_progress)
      response = client.create(:apex_component, { :full_name => 'component', :label => 'test', :content => 'test' })
    end

    it "responds to dynamically defined methods" do
      client.respond_to?(:create_apex_class).should eq(true)
    end

    describe "dynamically built methods" do

      it "works just like .create" do
        savon.expects(:create).with(:metadata => [{:full_name => 'component', :label => 'test'}], :attributes! => {'ins0:metadata' => {'xsi:type' => 'wsdl:ApexComponent'}}).returns(:in_progress)
        response = client.create_apex_component(:full_name => 'component', :label => 'test')
        response.should be_a(Metaforce::Transaction)
      end

    end

  end

  describe ".delete" do

    it "returns a transaction" do
      savon.expects(:delete).with(:metadata => [{:full_name => 'component'}], :attributes! => {'ins0:metadata' => {'xsi:type' => 'wsdl:ApexComponent'}}).returns(:in_progress)
      response = client.delete(:apex_component, { :full_name => 'component'})
      response.should be_a(Metaforce::Transaction)
    end

    it "responds to dynamically defined methods" do
      client.respond_to?(:delete_apex_class).should eq(true)
    end

  end

  describe ".update" do

    it "returns a transaction" do
      savon.expects(:update).with(:metadata => [{:full_name => 'component', :label => 'test'}], :attributes! => {'ins0:metadata' => {'xsi:type' => 'wsdl:ApexComponent'}}).returns(:in_progress)
      response = client.update(:apex_component, { :full_name => 'component', :label => 'test'})
      response.should be_a(Metaforce::Transaction)
    end

    it "responds to dynamically defined methods" do
      client.respond_to?(:update_apex_class).should eq(true)
    end

  end
end
