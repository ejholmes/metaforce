require 'savon'

module Metaforce
  module Metadata
    class Client
      def initialize(options={})
        @session = Services::Client.new(options).session
      end

      def list
        client = Savon::Client.new File.expand_path("../../../../wsdl/23.0/metadata.xml", __FILE__)
        response = client.request(:list_metadata)
      end
    end
  end
end
