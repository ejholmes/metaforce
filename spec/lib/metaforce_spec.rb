require 'spec_helper'

describe Metaforce do
  describe '#new' do
    let(:klass) { described_class.new(session_id: 'foobar') }
    subject { klass }

    its(:metadata) { should be_a Metaforce::Metadata::Client }
    its(:services) { should be_a Metaforce::Services::Client }
  end

  describe '#login' do
    let(:args) { {:username => 'foo', :password => 'foobar', :security_token => 'whizbang'} }

    it 'proxies the login call' do
      Metaforce::Login.should_receive(:new).with('foo', 'foobar', 'whizbang').and_call_original
      Metaforce::Login.any_instance.should_receive(:login)
      described_class.login args
    end
  end
end
