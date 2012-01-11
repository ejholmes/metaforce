module Metaforce
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end

  class Configuration
    attr_accessor :sfdc_api_version

    def initializer
      @sfdc_api_version = "23.0"
    end
  end
end
