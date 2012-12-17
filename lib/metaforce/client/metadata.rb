require 'metaforce/client/metadata/deploy'
require 'metaforce/client/metadata/retrieve'

module Metaforce
  class Client
    module Metadata
      include Metaforce::Client::Metadata::Deploy
      include Metaforce::Client::Metadata::Retrieve
      
      # Public: Used to interact with the Metadata API.
      def metadata
        @metadata ||= Metaforce::Metadata::Client.new(@options)
      end

    end
  end
end
