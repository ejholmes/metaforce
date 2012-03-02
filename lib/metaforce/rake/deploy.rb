require 'metaforce'
require 'rake'
require 'rake/tasklib'

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
          puts @directory
        end
      end

    end
    
  end
end
