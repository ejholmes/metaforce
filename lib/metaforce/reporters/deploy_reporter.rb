require 'metaforce/reporters/base_reporter'

module Metaforce
  module Reporters
    class DeployReporter < BaseReporter

      def report
        report_problems
        report_failed_tests
        report_test_results if report_test_results?
      end

      def report_failed_tests
        return unless failures?
        say
        say "Failures:", :red
        say
        failures.each { |failure| failed(failure) }
      end

      def report_test_results
        say
        say "Finished in #{total_time} seconds"
        say "#{num_tests} tests, #{num_failures} failures", failures? ? :red : :green
      end

      def failed(failure)
        say "#{short_padding}#{failure.stack_trace}:", :red
        say "#{long_padding}#{failure.message}"
        say
      end

      def failures?
        num_failures > 0
      end

      def issues?
        problems? || failures?
      end

    private

      def report_test_results?
        @results.success && problems.empty?
      end

      def test_results
        @results.run_test_result
      end

      def failures
        @failures ||= Array[test_results.failures].compact.flatten
      end

      def total_time
        test_results.total_time
      end

      def num_tests
        test_results.num_tests_run.to_i
      end

      def num_failures
        test_results.num_failures.to_i
      end

    end
  end
end
