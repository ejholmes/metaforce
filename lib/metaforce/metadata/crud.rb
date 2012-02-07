require 'base64'

module Metaforce
  module Metadata
    class Client

      def create(type, metadata={})
        metadata = [metadata] unless metadata.is_a?(Array)
        metadata = encode_content(metadata)
        response = @client.request(:create) do |soap|
          soap.header = @header
          soap.body = {
            :metadata => metadata,
            :attributes! => { "ins0:metadata" => { "xsi:type" => "wsdl:#{type.to_s}" } }
          }
        end
        Transaction.new self, response.body[:create_response][:result][:id]
      end

      def delete(type, metadata={})
        metadata = [metadata] unless metadata.is_a?(Array)
        response = @client.request(:delete) do |soap|
          soap.header = @header
          soap.body = {
            :metadata => metadata,
            :attributes! => { "ins0:metadata" => { "xsi:type" => "wsdl:#{type.to_s}" } }
          }
        end
        Transaction.new self, response.body[:delete_response][:result][:id]
      end

      Metaforce::Metadata::Types.all.each do |type, value|
        define_method("create_#{type}".to_sym) do |metadata|
          create(value[:name], metadata)
        end
        define_method("delete_#{type}".to_sym) do |metadata|
          delete(value[:name], metadata)
        end
      end

    private

      def encode_content(metadata)
        metadata.each do |m|
          m[:content] = Base64.encode64(m[:content]) if m.has_key?(:content)
        end
        metadata
      end

    end
  end
end
