require 'spec_helper'

describe Metaforce do
  describe '#new' do
    let(:options) { {} }
    subject { described_class.new(options) }

    its(:metadata) { should be_a Metaforce::Metadata::Client }
    its(:services) { should be_a Metaforce::Services::Client }
  end
end
