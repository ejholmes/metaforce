module Metaforce
  class Client
    def initialize(options)
      @options = options
    end

    # Public: Used to interact with the Metadata API.
    def metadata
      @metadata ||= Metaforce::Metadata::Client.new(@options)
    end

    # Public: Used to interact with the Services API.
    def services
      @services ||= Metaforce::Services::Client.new(@options)
    end
  end
end
