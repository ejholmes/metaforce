require 'spec_helper'

describe Metaforce::Job::Retrieve do
  let(:client) { double('metadata client') }
  let(:job) { described_class.new client }

  describe '.result' do
    let(:response) { Hashie::Mash.new(success: true) }

    before do
      client.should_receive(:status).with(job.id, :retrieve).and_return(response)
    end

    subject { job.result }
    it { should eq response }
  end

  describe '.zip_file' do
    let(:response) { Hashie::Mash.new(success: true, zip_file: 'foobar') }

    before do
      client.should_receive(:status).with(job.id, :retrieve).and_return(response)
    end

    subject { job.zip_file }
    it { should eq "~\x8A\e" }
  end
end
