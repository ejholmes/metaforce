require 'spec_helper'

describe Metaforce::Services::Client do
  let(:client) { described_class.new(:session_id => 'foobar', :server_url => 'https://na12-api.salesforce.com/services/Soap/u/23.0/00DU0000000Ilbh') }

  it_behaves_like 'a client'

  describe '.describe_layout' do
    context 'without a record type id' do
      before do
        savon.expects(:describe_layout).with('sObjectType' => 'Account').returns(:success)
      end

      subject { client.describe_layout('Account') }
      it { should be_a Hash }
    end

    context 'with a record type id' do
      before do
        savon.expects(:describe_layout).with('sObjectType' => 'Account', 'recordTypeID' => '1234').returns(:success)
      end

      subject { client.describe_layout('Account', '1234') }
      it { should be_a Hash }
    end
  end

  describe '.send_email' do
    before do
      savon.expects(:send_email).with(:messages => { :to_addresses => "foo@bar.com", :subject => "foo", :plain_text_body => "bar" },
                                      :attributes! => { "ins0:messages" => { "xsi:type" => "ins0:SingleEmailMessage" } }).returns(:success)
    end

    subject { client.send_email(:to_addresses => 'foo@bar.com', subject: 'foo', plain_text_body: 'bar') }
    it { should be_a Hash}
  end
end
