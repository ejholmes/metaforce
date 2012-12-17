require 'metaforce/client/metadata/deploy'
require 'metaforce/client/metadata/retrieve'
require 'metaforce/client/metadata/crud'

module Metaforce
  class Client
    module Metadata
      include Metaforce::Client::Metadata::Deploy
      include Metaforce::Client::Metadata::Retrieve
      include Metaforce::Client::Metadata::CRUD
      
      # Public: Used to interact with the Metadata API.
      def metadata
        @metadata ||= Metaforce::Metadata::Client.new(@options)
      end

    end
  end
end
