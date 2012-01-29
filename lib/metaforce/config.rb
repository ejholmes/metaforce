module Metaforce
  class << self
    # Returns the current Configuration
    #
    #    Metaforce.configuration.username = "username"
    #    Metaforce.configuration.password = "password"
    def configuration
      @configuration ||= Configuration.new
    end

    # Yields the Configuration
    #
    #    Metaforce.configure do |config|
    #      config.username = "username"
    #      config.password = "password"
    #    end
    def configure
      yield configuration
    end
  end

  class Configuration
    # The Salesforce API version to use. Defaults to 23.0
    attr_accessor :api_version
    # The username to use during login.
    attr_accessor :username
    # The password to use during login.
    attr_accessor :password
    # The security token to use during login.
    attr_accessor :security_token
    # Set this to true if you're authentication with a Sandbox instance.
    # Defaults to false.
    attr_accessor :test

    def initialize
      @api_version = "23.0"
      @test = false
    end
  end
end
