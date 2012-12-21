require 'spec_helper'

describe Metaforce::Job::Deploy do
  let(:client) { double('metadata client') }
  let(:path) { File.expand_path('../../../fixtures/payload.zip', __FILE__) }
  let(:job) { described_class.new client, path }

  describe '.perform' do
    subject { job.perform }

    context 'when the path is a file' do
      before do
        client.should_receive(:_deploy).with(/^UEsDBA.*/, {}).and_return(Hashie::Mash.new(id: '1234'))
        client.should_receive(:status).any_number_of_times.and_return(Hashie::Mash.new(done: true, state: 'Completed'))
      end

      it { should eq job }
      its(:id) { should eq '1234' }
    end

    context 'when the path is a directory' do
      before do
        client.should_receive(:_deploy).with(/.*1stwAAAJI.*/, {}).and_return(Hashie::Mash.new(id: '1234'))
        client.should_receive(:status).any_number_of_times.and_return(Hashie::Mash.new(done: true, state: 'Completed'))
      end

      let(:path) { File.expand_path('../../../fixtures', __FILE__) }
      it { should eq job }
      its(:id) { should eq '1234' }
    end
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
