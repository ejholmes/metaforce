require 'spec_helper'

describe Metaforce::Client do
  let(:options) { { session_id: 'foobar' } }
  let(:client) { described_class.new(options) }

  describe '.metadata' do
    subject { client.metadata }
    it { should be_a Metaforce::Metadata::Client }
  end

  describe '.services' do
    subject { client.services }
    it { should be_a Metaforce::Services::Client }
  end

  describe '.method_missing' do
    %w[services metadata].each do |type|
      context "when the #{type} client responds to method" do
        it 'proxies to the method' do
          client.send(type.to_sym).should_receive(:respond_to?).with(:foobar, false).and_return(true)
          client.send(type.to_sym).should_receive(:foobar)
          client.foobar
        end
      end
    end

    context 'when neither client responds to method' do
      it 'raises an exception' do
        expect { client.foobar }.to raise_error NoMethodError
      end
    end
  end

  describe '.inspect' do
    subject { client.inspect }
    it { should eq '#<Metaforce::Client @options={:session_id=>"foobar"}>' }
  end
end
