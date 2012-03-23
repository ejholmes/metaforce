require 'base64'

module Metaforce
  module Metadata
    module CRUD

      def create(type, metadata={})
        type = type.to_s.camelcase
        metadata = [metadata] unless metadata.is_a?(Array)
        metadata = encode_content(metadata)
        response = @client.request(:create) do |soap|
          soap.header = @header
          soap.body = {
            :metadata => metadata,
            :attributes! => { "ins0:metadata" => { "xsi:type" => "wsdl:#{type}" } }
          }
        end
        Transaction.new self, response.body[:create_response][:result][:id]
      end

      def update(type, metadata={})
        type = type.to_s.camelcase
        metadata = [metadata] unless metadata.is_a?(Array)
        metadata = encode_content(metadata)
        response = @client.request(:update) do |soap|
          soap.header = @header
          soap.body = {
            :metadata => metadata,
            :attributes! => { "ins0:metadata" => { "xsi:type" => "wsdl:#{type}" } }
          }
        end
        Transaction.new self, response.body[:update_response][:result][:id]
      end

      def delete(type, metadata={})
        type = type.to_s.camelcase
        metadata = [metadata] unless metadata.is_a?(Array)
        response = @client.request(:delete) do |soap|
          soap.header = @header
          soap.body = {
            :metadata => metadata,
            :attributes! => { "ins0:metadata" => { "xsi:type" => "wsdl:#{type}" } }
          }
        end
        Transaction.new self, response.body[:delete_response][:result][:id]
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

Metaforce::Metadata::Client.send :include, Metaforce::Metadata::CRUD
