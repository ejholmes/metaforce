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
        return unless problems.any?
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

    private

      def messages
        @messages ||= begin
          messages = @results.messages || []
          messages = [messages] unless messages.is_a?(Array)
          messages
        end
      end

      def problems
        messages.select { |message| message.problem }
      end

    end
  end
end
