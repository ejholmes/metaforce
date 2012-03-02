require 'metaforce'
require 'term/ansicolor'
require 'rake'
require 'rake/tasklib'
include Term::ANSIColor

module Metaforce
  module Rake

    class DeployTask < ::Rake::TaskLib
      attr_accessor :name

      # The directory to deploy
      attr_accessor :directory

      def initialize(name = 'metaforce:deploy')
        @name      = name
        @directory = File.expand_path('src')
        yield self if block_given?
        define
      end

      def define
        task @name do
          client = Metaforce::Rake.client
          d = client.deploy(@directory)
          puts green "Deployed #{@directory} successfully" if d.result[:success]
        end
      end

    end
    
  end
end
