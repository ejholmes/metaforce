require 'spec_helper'
require 'metaforce/reporters/retrieve_reporter'

describe Metaforce::Reporters::RetrieveReporter do
  let(:results) { Hashie::Mash.new(success: true) }
  let(:reporter) { described_class.new results }

  describe '.report' do
    it 'reports the problems' do
      reporter.should_receive(:report_problems)
      reporter.report
    end
  end
end
