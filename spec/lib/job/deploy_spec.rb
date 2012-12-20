require 'spec_helper'

describe Metaforce::Job::Deploy do
  let(:client) { double('metadata client') }
  let(:path) { File.expand_path('../../../fixtures/payload.zip', __FILE__) }
  let(:job) { described_class.new client, path }

  describe '.payload' do
    subject { job.payload }

    context 'when the path is a file' do
      it { should be_a String }
    end

    context 'when the path is a directory' do
      let(:path) { File.expand_path('../../../fixtures', __FILE__) }
      it { should be_a String }
    end
  end

  describe '.perform' do
    before do
      client.should_receive(:_deploy).with(job.payload, {}).and_return(Hashie::Mash.new(id: '1234'))
      client.should_receive(:status).any_number_of_times.and_return(Hashie::Mash.new(done: true, state: 'Completed'))
    end

    subject { job.perform }
    it { should eq job }
    its(:id) { should eq '1234' }
  end

  describe '.result' do
    let(:response) { Hashie::Mash.new(success: true) }

    before do
      client.should_receive(:status).with(job.id, :deploy).and_return(response)
    end

    subject { job.result }
    it { should eq response }
  end

  describe '.success?' do
    let(:response) { Hashie::Mash.new(success: true) }

    before do
      client.should_receive(:status).with(job.id, :deploy).and_return(response)
    end

    subject { job.success? }
    it { should be_true }
  end
end
