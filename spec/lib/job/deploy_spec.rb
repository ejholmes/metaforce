require 'spec_helper'

describe Metaforce::Job::Deploy do
  let(:client) { double('metadata client') }
  let(:job) { described_class.new client, File.expand_path('../../../fixtures/payload.zip', __FILE__) }

  describe '.payload' do
    subject { job.payload }
    it { should be_a String }
  end

  describe '.perform' do
    before do
      client.should_receive(:deploy).with(job.payload, {}).and_return('1234')
    end

    subject { job.perform }
    it { should be_a String }
  end
end
