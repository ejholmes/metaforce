module Metaforce
  module Metadata
    class Client < Metaforce::AbstractClient
      require 'metaforce/metadata/client/file'
      require 'metaforce/metadata/client/crud'

      include Metaforce::Metadata::Client::File
      include Metaforce::Metadata::Client::CRUD

      endpoint :metadata_server_url
      wsdl Metaforce.configuration.metadata_wsdl
    end
  end
end
