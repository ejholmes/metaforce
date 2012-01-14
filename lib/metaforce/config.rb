module Metaforce
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield @configuration
    end
  end

  class Configuration
    attr_accessor :api_version
    attr_accessor :username
    attr_accessor :password
    attr_accessor :security_token
    attr_accessor :test

    def initialize
      @api_version = "23.0"
      @test = false
    end
  end
end
