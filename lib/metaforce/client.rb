module Metaforce
  class Client
    def initialize(options = {})
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

    def inspect
      "#<#{self.class} @options=#{@options.inspect}>"
    end

    def method_missing(method, *args, &block)
      if metadata.respond_to? method, false
        metadata.send(method, *args, &block)
      elsif services.respond_to? method, false
        services.send(method, *args, &block)
      else
        super
      end
    end
  end
end
