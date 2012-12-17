require 'metaforce/client/metadata'
require 'metaforce/client/services'

module Metaforce
  class Client
    include Metaforce::Client::Metadata
    include Metaforce::Client::Services

    def initialize(options)
      @options = options
    end
  end
end
