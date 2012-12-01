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

  describe '.deploy' do
    before do
      savon.expects(:deploy).with(:zip_file => 'foobar', :deploy_options => {}).returns(:in_progress)
    end

    subject { client.deploy('foobar') }
    it { should be_a Hash }
  end

  describe '.retrieve' do
    before do
      savon.expects(:retrieve).returns(:in_progress)
    end
  end
end
