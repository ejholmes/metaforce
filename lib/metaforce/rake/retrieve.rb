require 'metaforce'
require 'term/ansicolor'
require 'rake'
require 'rake/tasklib'
include Term::ANSIColor

module Metaforce
  module Rake

    class RetrieveTask < ::Rake::TaskLib
      attr_accessor :name

      # Path to the manifest file
      attr_accessor :manifest

      # The directory to unzip the retrieved files to
      attr_accessor :directory

      def initialize(name = 'metaforce:retrieve')
        @name      = name
        @manifest  = File.expand_path('src/package.xml')
        @directory = File.expand_path('retrieved')
        yield self if block_given?
        define
      end

      def define
        task @name do
          client = Metaforce::Rake.client
          r = client.retrieve_unpackaged(@manifest).to(@directory)
          puts green "Files retrieved sucessfully"
        end
      end

    end
    
  end
end
