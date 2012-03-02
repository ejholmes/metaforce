require 'metaforce'
require 'term/ansicolor'
require 'rake'
require 'rake/tasklib'
include Term::ANSIColor

module Metaforce
  module Rake

    class TestsTask < ::Rake::TaskLib
      attr_accessor :name

      # The directory to deploy
      attr_accessor :directory

      def initialize(name = 'metaforce:tests:ci')
        @name      = name
        @directory = File.expand_path('src')
        yield self if block_given?
        define
      end

      def define
        desc "Deploy metadata, run all tests, then undeploy"
        task @name do
          ENV['env'] = ENV['env'] || 'ci'
          client = Metaforce::Rake.client
          Metaforce.log = false
          result = client.deploy(@directory, :options => { :run_all_tests => true }).result
          failures = result[:run_test_result][:failures]

          if failures
            failures = [failures] unless failures.is_a?(Array)
            puts "Failures:"
            failures.each_with_index do |failure, index|
              index = index + 1
              puts
              puts         "\t#{index}) #{failure[:method_name]}"
              puts red     "\t   #{failure[:message]}"
              puts
              puts magenta "\t   ##{failure[:stack_trace]}"
              puts
            end
          end

          color = failures ? :red : :green
          puts "Finished in #{Float(result[:run_test_result][:total_time]) / 100} seconds"
          puts send(color, "#{result[:run_test_result][:num_tests_run]} tests, #{result[:run_test_result][:num_failures]} failures")

          if failures
            puts "\nFailed tests:\n"
            failures.each do |failure|
              puts "#{red failure[:stack_trace]} #{magenta "# #{failure[:method_name]}"}"
            end
          end

          abort if failures
        end
      end
    end
  end
end
