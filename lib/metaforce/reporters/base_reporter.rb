require 'thor/shell/color'

module Metaforce
  module Reporters
    class BaseReporter < Thor::Shell::Color
      def initialize(results)
        super()
        @results = results
      end

      def report
      end

      def report_problems
        return unless problems?
        say
        say "Problems:", :red
        say
        problems.each { |message| problem(message) }
      end

      def problem(message)
        say "#{short_padding}#{message.file_name}:#{message.line_number}", :red
        say "#{long_padding}#{message.problem}"
        say
      end

      def short_padding
        '  '
      end

      def long_padding
        '     '
      end

      def problems?
        problems.any?
      end

      def issues?
        problems?
      end

    private

      def messages
        @messages ||= Array[@results.messages].compact.flatten
      end

      def problems
        messages.select { |message| message.problem }
      end

    end
  end
end
