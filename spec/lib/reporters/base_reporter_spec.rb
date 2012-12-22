require 'spec_helper'
require 'metaforce/reporters/base_reporter'

describe Metaforce::Reporters::BaseReporter do
  let(:results) { Hashie::Mash.new(success: true) }
  let(:reporter) { described_class.new results }

  describe '.problem' do
    context 'when a line_number is present' do
      let(:problem) { Hashie::Mash.new(file_name: 'path/file', line_number: '10', problem: 'Foobar') }

      it 'prints the problem' do
        reporter.should_receive(:say).with('  path/file:10', :red)
        reporter.should_receive(:say).with('     Foobar')
        reporter.should_receive(:say).with
        reporter.problem(problem)
      end
    end

    context 'when there is no line number present' do
      let(:problem) { Hashie::Mash.new(file_name: 'path/file', problem: 'Foobar') }

      it 'prints the problem' do
        reporter.should_receive(:say).with('  path/file:', :red)
        reporter.should_receive(:say).with('     Foobar')
        reporter.should_receive(:say).with
        reporter.problem(problem)
      end
    end
  end

  describe '.report_problems' do
    context 'when there are no problems' do
      it 'does not report any problems' do
        reporter.should_receive(:say).never
        reporter.should_receive(:problem).never
        reporter.report_problems
      end
    end

    context 'when there are problems' do
      let(:results) { Hashie::Mash.new(success: true, messages: { problem: 'Problem', file_name: 'path/file', line_number: '10' }) }

      it 'prints each problem' do
        reporter.should_receive(:say)
        reporter.should_receive(:say).with('Problems:', :red)
        reporter.should_receive(:say)
        reporter.should_receive(:problem)
        reporter.report_problems
      end
    end
  end

  describe '.problems?' do
    subject { reporter.problems? }

    context 'when there are no problems' do
      it { should be_false }
    end

    context 'when there are problems' do
      let(:results) { Hashie::Mash.new(success: true, messages: { problem: 'Problem', file_name: 'path/file', line_number: '10' }) }
      it { should be_true }
    end
  end

  describe '.issues?' do
    subject { reporter.issues? }

    context 'when there are no problems' do
      it { should be_false }
    end

    context 'when there are problems' do
      let(:results) { Hashie::Mash.new(success: true, messages: { problem: 'Problem', file_name: 'path/file', line_number: '10' }) }
      it { should be_true }
    end
  end
end
