require 'base64'

module Metaforce
  module Metadata
    module CRUD

      # Create metadata
      #
      # == Examples
      #
      #   client.create(:apex_page, :full_name => 'TestPage')
      def create(type, metadata={})
        metadata = prepare_metadata(type, metadata)
        type = type.to_s.camelcase
        response = @client.request(:create) do |soap|
          soap.header = @header
          soap.body = {
            :metadata => metadata,
            :attributes! => { "ins0:metadata" => { "xsi:type" => "wsdl:#{type}" } }
          }
        end
        Transaction.new self, response.body[:create_response][:result][:id]
      end

      # Update metadata
      #
      # == Examples
      #
      #   client.update(:apex_page, 'OldPage', :full_name => 'NewPage')
      def update(type, current_name, metadata={})
        metadata = prepare_metadata(type, metadata)
        type = type.to_s.camelcase
        response = @client.request(:update) do |soap|
          soap.header = @header
          soap.body = {
            :metadata => {
              :current_name => current_name,
              :metadata => metadata,
              :attributes! => { :metadata => { "xsi:type" => "wsdl:#{type}" } }
            }
          }
        end
        Transaction.new self, response.body[:update_response][:result][:id]
      end

      # Delete metadata
      #
      # == Examples
      #
      #   client.delete(:apex_page, :full_name => 'TestPage')
      def delete(type, full_name)
        full_name = [full_name] unless full_name.is_a?(Array)
        metadata = []
        full_name.each do |f|
          metadata << { :full_name => f }
        end
        type = type.to_s.camelcase
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

      def prepare_metadata(type, metadata)
        metadata = [metadata] unless metadata.is_a?(Array)
        metadata.each_with_index do |m, i|
          template = Metaforce::Metadata::MetadataFile.template(type)
          m = template.merge(m) if template
          metadata[i] = m
        end
        metadata = encode_content(metadata)
      end

      def encode_content(metadata)
        metadata.each do |m|
          m[:content] = Base64.encode64(m[:content]) if m.has_key?(:content)
        end
        metadata
      end

      def method_missing(name, *args, &block)
        if name =~ /^create_(.*)$/
          create($1.to_sym, *args)
        elsif name =~ /^update_(.*)$/
          update($1.to_sym, *args)
        elsif name =~ /^delete_(.*)$/
          delete($1.to_sym, *args)
        else
          super
        end
      end

    end
  end
end

Metaforce::Metadata::Client.send :include, Metaforce::Metadata::CRUD
