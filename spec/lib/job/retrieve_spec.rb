require 'spec_helper'
require 'base64'

describe Metaforce::Job::Retrieve do
  let(:client) { double('metadata client') }
  let(:job) { described_class.new client }

  describe '.result' do
    let(:response) { Hashie::Mash.new(success: true) }

    before do
      expect(client).to receive(:status).with(job.id, :retrieve).and_return(response)
    end

    subject { job.result }
    it { should eq response }
  end

  describe '.zip_file' do
    zip_file_content = 'foobar'
    let(:response) { Hashie::Mash.new(success: true, zip_file: zip_file_content) }

    before do
      expect(client).to receive(:status).with(job.id, :retrieve).and_return(response)
    end

    subject { job.zip_file }
    #it { should eq "~\x8A\e" }
    it { should eq Base64.decode64(zip_file_content) }
  end
end
