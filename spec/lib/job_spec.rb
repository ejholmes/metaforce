require 'spec_helper'

describe Metaforce::Job do
  let(:client) { double('client') }
  let(:job) { described_class.new(client) }

  describe '.perform' do
    it 'starts a heart beat' do
      job.should_receive(:start_heart_beat)
      job.perform
    end
  end

  describe '.started?' do
    subject { job.started? }

    context 'when .perform has been called and an @id has been set' do
      before do
        job.instance_variable_set(:@id, '1234')
      end

      it { should be_true }
    end

    context 'when .perform has not been called and no @id has been set' do
      it { should be_false }
    end
  end

  describe '.on_complete' do
    it 'allows the user to register an on_complete callback' do
      client.should_receive(:status).any_number_of_times.and_return(Hashie::Mash.new(done: true, state: 'Completed'))
      called = false
      block = lambda { |job| called = true }
      job.on_complete &block
      job.perform
      expect(called).to be_true
    end
  end

  describe '.on_error' do
    it 'allows the user to register an on_error callback' do
      client.should_receive(:status).any_number_of_times.and_return(Hashie::Mash.new(done: true, state: 'Error'))
      called = false
      block = lambda { |job| called = true }
      job.on_error &block
      job.perform
      expect(called).to be_true
    end
  end

  describe '.status' do
    before do
      client.should_receive(:status)
    end

    subject { job.status }
    it { should be_nil }
  end

  describe '.done?' do
    subject { job.done? }

    context 'when done' do
      before do
        client.should_receive(:status).and_return(Hashie::Mash.new(done: true))
      end

      it { should be_true }
    end

    context 'when not done' do
      before do
        client.should_receive(:status).and_return(Hashie::Mash.new(done: false))
      end

      it { should be_false }
    end
  end

  describe '.state' do
    subject { job.state }

    context 'when done' do
      before do
        client.should_receive(:status).and_return(Hashie::Mash.new(done: true, state: 'Completed'))
      end

      it { should eq 'Completed' }
    end

    context 'when not done' do
      before do
        client.should_receive(:status).once.and_return(Hashie::Mash.new(done: false))
      end

      it { should be_false }
    end
  end

  %w[Queued InProgress Completed Error].each do |state|
    describe ".#{state.underscore}?" do
      before do
        client.should_receive(:status).and_return(Hashie::Mash.new(done: true, state: state))
      end

      subject { job.send(:"#{state.underscore}?") }
      it { should be_true }
    end
  end
end
