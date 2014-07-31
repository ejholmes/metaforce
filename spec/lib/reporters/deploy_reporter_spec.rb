require 'spec_helper'
require 'metaforce/reporters/deploy_reporter'

describe Metaforce::Reporters::DeployReporter do
  let(:results) { Hashie::Mash.new(success: true) }
  let(:reporter) { described_class.new results }

  describe '.failed' do
    let(:failure) { Hashie::Mash.new(stack_trace: 'stack trace', message: 'message') }

    it 'prints the failure' do
      expect(reporter).to receive(:say).with('  stack trace:', :red)
      expect(reporter).to receive(:say).with('     message')
      expect(reporter).to receive(:say).with( no_args )
      reporter.failed(failure)
    end
  end

  describe '.report' do
    context 'when the deploy was successfull' do
      it 'should report everything' do
        expect(reporter).to receive(:report_problems)
        expect(reporter).to receive(:report_failed_tests)
        expect(reporter).to receive(:report_test_results)
        reporter.report
      end
    end

    context 'when the deploy was not successful' do
      let(:results) { Hashie::Mash.new(success: false) }

      it 'should report everything except test results' do
        expect(reporter).to receive(:report_problems)
        expect(reporter).to receive(:report_failed_tests)
        expect(reporter).to receive(:report_test_results).never
        reporter.report
      end
    end
  end

  describe '.report_failed_tests' do
    let(:results) { Hashie::Mash.new(success: true, run_test_result: { num_failures: num_failures, failures: failures }) }

    context 'when there are no failed tests' do
      let(:failures) { nil }
      let(:num_failures) { '0' }

      it 'does not report any failed tests' do
        expect(reporter).to receive(:say).never
        expect(reporter).to receive(:failed).never
        reporter.report_failed_tests
      end
    end

    context 'when there are failed tests' do
      context 'passed as an object' do
        let(:failures) { { stack_trace: 'stack trace', message: 'message' } }
        let(:num_failures) { '1' }

        it 'prints each failed tests' do
          expect(reporter).to receive(:say)
          expect(reporter).to receive(:say).with('Failures:', :red)
          expect(reporter).to receive(:say)
          expect(reporter).to receive(:failed)
          reporter.report_failed_tests
        end
      end
      
      context 'passed as an array' do
        let(:failures) { [{ stack_trace: 'stack trace', message: 'message' }, { stack_trace: 'stack trace 2', message: 'message 2' }] }
        let(:num_failures) { '2' }

        it 'prints each failed tests' do
          expect(reporter).to receive(:say)
          expect(reporter).to receive(:say).with('Failures:', :red)
          expect(reporter).to receive(:say)
          expect(reporter).to receive(:failed).twice
          reporter.report_failed_tests
        end
      end
    end
  end

  describe '.report_test_results' do
    let(:results) { Hashie::Mash.new(success: true, run_test_result: { total_time: '20', num_tests_run: '10', num_failures: num_failures }) }

    context 'when there are failures' do
      let(:num_failures) { '5' }

      it 'prints the test results in red' do
        expect(reporter).to receive(:say)
        expect(reporter).to receive(:say).with("Finished in 20 seconds")
        expect(reporter).to receive(:say).with("10 tests, 5 failures", :red)
        reporter.report_test_results
      end
    end

    context 'when there are no failures' do
      let(:num_failures) { '0' }

      it 'prints the test results in red' do
        expect(reporter).to receive(:say)
        expect(reporter).to receive(:say).with("Finished in 20 seconds")
        expect(reporter).to receive(:say).with("10 tests, 0 failures", :green)
        reporter.report_test_results
      end
    end
  end

  describe '.failures?' do
    let(:results) { Hashie::Mash.new(success: true, run_test_result: { total_time: '20', num_tests_run: '10', num_failures: num_failures }) }
    subject { reporter.failures? }

    context 'when there are failures' do
      let(:num_failures) { '5' }
      it { should be_truthy }
    end

    context 'when there are no failures' do
      let(:num_failures) { '0' }
      it { should be_falsey }
    end
  end
end
