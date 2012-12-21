require 'metaforce/reporters/base_reporter'

module Metaforce
  module Reporters
    class RetrieveReporter < BaseReporter
      def report
        report_problems
      end
    end
  end
end
