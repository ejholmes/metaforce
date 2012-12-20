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
end
