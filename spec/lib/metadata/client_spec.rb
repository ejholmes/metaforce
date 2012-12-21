require 'spec_helper'

describe Metaforce::Metadata::Client do
  let(:client) { described_class.new(:session_id => 'foobar', :metadata_server_url => 'https://na12-api.salesforce.com/services/Soap/u/23.0/00DU0000000Ilbh') }

  it_behaves_like 'a client'

  describe '.list_metadata' do
    context 'with a single symbol' do
      before do
        savon.expects(:list_metadata).with(:queries => [{:type => 'ApexClass'}]).returns(:objects)
      end

      subject { client.list_metadata(:apex_class) }
      it { should be_an Array }
    end

    context 'with a single string' do
      before do
        savon.expects(:list_metadata).with(:queries => [{:type => 'ApexClass'}]).returns(:objects)
      end

      subject { client.list_metadata('ApexClass') }
      it { should be_an Array }
    end
  end

  describe '.describe' do
    context 'with no version' do
      before do
        savon.expects(:describe_metadata).with(nil).returns(:success)
      end

      subject { client.describe }
      it { should be_a Hash }
    end

    context 'with a version' do
      before do
        savon.expects(:describe_metadata).with(:api_version => '18.0').returns(:success)
      end

      subject { client.describe('18.0') }
      it { should be_a Hash }
    end
  end

  describe '.status' do
    context 'with a single id' do
      before do
        savon.expects(:check_status).with(:ids => ['1234']).returns(:done)
      end

      subject { client.status '1234' }
      it { should be_a Hash }
    end
  end

  describe '._deploy' do
    before do
      savon.expects(:deploy).with(:zip_file => 'foobar', :deploy_options => {}).returns(:in_progress)
    end

    subject { client._deploy('foobar') }
    it { should be_a Hash }
  end

  describe '.deploy' do
    subject { client.deploy File.expand_path('../../path/to/zip') }
    it { should be_a Metaforce::Job::Deploy }
  end

  describe '._retrieve' do
    let(:options) { double('options') }

    before do
      savon.expects(:retrieve).with(:retrieve_request => options).returns(:in_progress)
    end

    subject { client._retrieve(options) }
    it { should be_a Hash }
  end

  describe '.retrieve' do
    subject { client.retrieve }
    it { should be_a Metaforce::Job::Retrieve }
  end

  describe '.retrieve_unpackaged' do
    let(:manifest) { Metaforce::Manifest.new(:custom_object => ['Account']) }
    subject { client.retrieve_unpackaged(manifest) }
    it { should be_a Metaforce::Job::Retrieve }
  end

  describe '._create' do
    before do
      savon.expects(:create).with(:metadata => [{:full_name => 'component', :label => 'test', :content => "Zm9vYmFy\n"}], :attributes! => {'ins0:metadata' => {'xsi:type' => 'ins0:ApexComponent'}}).returns(:in_progress)
    end

    subject { client._create(:apex_component, :full_name => 'component', :label => 'test', :content => 'foobar') }
    it { should be_a Hash }
  end

  describe '._delete' do
    context 'with a single name' do
      before do
        savon.expects(:delete).with(:metadata => [{:full_name => 'component'}], :attributes! => {'ins0:metadata' => {'xsi:type' => 'ins0:ApexComponent'}}).returns(:in_progress)
      end

      subject { client._delete(:apex_component, 'component') }
      it { should be_a Hash }
    end

    context 'with multiple' do
      before do
        savon.expects(:delete).with(:metadata => [{:full_name => 'component1'}, {:full_name => 'component2'}], :attributes! => {'ins0:metadata' => {'xsi:type' => 'ins0:ApexComponent'}}).returns(:in_progress)
      end

      subject { client._delete(:apex_component, 'component1', 'component2') }
      it { should be_a Hash }
    end
  end

  describe '._update' do
    before do
      savon.expects(:update).with(:metadata => {:current_name => 'old_component', :metadata => [{:full_name => 'component', :label => 'test', :content => "Zm9vYmFy\n"}], :attributes! => {:metadata => {'xsi:type' => 'ins0:ApexComponent'}}}).returns(:in_progress)
    end

    subject { client._update(:apex_component, 'old_component', :full_name => 'component', :label => 'test', :content => 'foobar') }
    it { should be_a Hash }
  end
end



