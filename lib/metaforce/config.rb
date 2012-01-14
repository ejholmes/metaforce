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

    def initialize
      @api_version = "23.0"
    end
  end
end
