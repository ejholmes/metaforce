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
      block = lambda { }
      job.on_complete &block
    end
  end
end
