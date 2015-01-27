require 'savon'
require 'hashie'
require 'active_support'
require 'active_support/core_ext'

require 'metaforce/version'
require 'metaforce/config'
require 'metaforce/job'
require 'metaforce/abstract_client'
require 'metaforce/services/client'
require 'metaforce/metadata/client'

module Metaforce
  autoload :Manifest, 'metaforce/manifest'
  autoload :Login,    'metaforce/login'
  autoload :Client,   'metaforce/client'

  class << self
    # Public: Initializes instances of the metadata and services api clients
    # and provides helper methods for deploying and retrieving code.
    def new(*args)
      Client.new(*args)
    end

    # Performs a login and retrurns the session
    def login(options={})
      options = HashWithIndifferentAccess.new(options)
      username       = options.fetch(:username, ENV['SALESFORCE_USERNAME'])
      password       = options.fetch(:password, ENV['SALESFORCE_PASSWORD'])
      security_token = options.fetch(:security_token, ENV['SALESFORCE_SECURITY_TOKEN'])
      Login.new(username, password, security_token).login
    end
  end
end
