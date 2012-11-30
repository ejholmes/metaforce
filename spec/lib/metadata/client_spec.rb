require 'spec_helper'

describe Metaforce::Metadata::Client do
  let(:client) { described_class.new(:session_id => 'foobar', :metadata_server_url => 'https://na12-api.salesforce.com/services/Soap/u/23.0/00DU0000000Ilbh') }

  describe '.list' do
    context 'with a single symbol' do
      before do
        savon.expects(:list_metadata).with(:queries => {:type => ['ApexClass']}).returns(:objects)
      end

      subject { client.list(:apex_class) }
      it { should be_an Array }
    end

    context 'with a single string' do
      before do
        savon.expects(:list_metadata).with(:queries => {:type => ['ApexClass']}).returns(:objects)
      end

      subject { client.list('ApexClass') }
      it { should be_an Array }
    end

    context 'with a list of symbols' do
      before do
        savon.expects(:list_metadata).with(:queries => {:type => ['ApexClass', 'ApexComponent']}).returns(:objects)
      end
    end
  end
end
