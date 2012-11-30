module Metaforce
  class << self
    attr_writer :log

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

    def log?
      @log ||= false
    end

    def log(message)
      return unless Metaforce.log?
      Metaforce.configuration.logger.send :debug, message
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
    # Set this to true if you're authenticating with a Sandbox instance.
    # Defaults to false.
    attr_accessor :host

    def initialize
      @api_version ||= '23.0'
      @host        ||= 'login.salesforce.com'
    end

    def partner_wsdl
      File.join(wsdl, 'partner.xml')
    end

    def metadata_wsdl
      File.join(wsdl, 'metadata.xml')
    end

    def endpoint
      "https://#{host}/services/Soap/u/#{api_version}"
    end

    def wsdl
      File.expand_path("../../../wsdl/#{api_version}", __FILE__)
    end

    def logger
      @logger ||= ::Logger.new STDOUT
    end
  end
end
