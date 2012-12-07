require 'spec_helper'

describe Metaforce do
  describe '#new' do
    let(:klass) { described_class.new(session_id: 'foobar') }
    subject { klass }

    its(:metadata) { should be_a Metaforce::Metadata::Client }
    its(:services) { should be_a Metaforce::Services::Client }

    describe '.deploy' do
      subject { klass.deploy File.expand_path('../../path/to/zip') }
      it { should be_a Metaforce::Job::Deploy }
    end

    describe '.retrieve' do
      subject { klass.retrieve }
      it { should be_a Metaforce::Job::Retrieve }
    end

    describe '.retrieve_unpackaged' do
      subject { klass.retrieve_unpackaged }
      it { should be_a Metaforce::Job::Retrieve }
    end
  end

  describe '#login' do
    let(:args) { ['foo', 'foobar', 'whizbang'] }

    it 'proxies the login call' do
      Metaforce::Login.should_receive(:new).with(*args).and_call_original
      Metaforce::Login.any_instance.should_receive(:login)
      described_class.login *args
    end
  end
end
