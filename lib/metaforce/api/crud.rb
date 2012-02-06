module Metaforce
  module Metadata
    class Client

      def create(type, metadata={})
        metadata = [metadata] unless metadata.is_a?(Array)
        response = @client.request(:create) do |soap|
          soap.header = @header
          soap.body = {
            :metadata => metadata,
            :attributes! => { "ins0:metadata" => { "xsi:type" => "wsdl:#{type.to_s}" } }
          }
        end
        response
      end

    end
  end
end
