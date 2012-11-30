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
    def new(options)
      Class.new do
        def initialize(options)
          @options = options
        end

        def metadata
          @metadata ||= Metadata::Client.new(@options)
        end

        def services
          @services ||= Services::Client.new(@options)
        end

        def deploy(path, options)
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
