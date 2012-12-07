require 'savon'
require 'hashie'
require 'active_support/core_ext'

require 'metaforce/version'
require 'metaforce/config'
require 'metaforce/login'
require 'metaforce/job'
require 'metaforce/client'
require 'metaforce/services'
require 'metaforce/metadata'

module Metaforce
  class << self
    # Public: Initializes instances of the metadata and services api clients
    # and provides helper methods for deploying and retrieving code.
    def new(options)
      Class.new do
        def initialize(options)
          @options = options
        end

        # Public: Used to interact with the Metadata API.
        def metadata
          @metadata ||= Metadata::Client.new(@options)
        end

        # Public: Used to interact with the Services API.
        def services
          @services ||= Services::Client.new(@options)
        end

        # Public: Deploy code to Salesforce.
        #
        # path    - A path to a zip file, or a directory to deploy.
        # options - Deploy options.
        #
        # Examples
        #
        #   client.deploy(File.expand_path('./src'))
        def deploy(path, options={})
          Job::Deploy.new(metadata, path, options)
        end

        def retrieve(options={})
          Job::Retrieve.new(metadata, options)
        end
      end.new(options)
    end

    # Performs a login and retrurns the session
    def login(*args)
      Login.new(*args).login
    end
  end
end
