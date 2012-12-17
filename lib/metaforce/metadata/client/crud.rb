module Metaforce
  module Metadata
    class Client
      module CRUD

        # Public: Create metadata
        #
        # Examples
        #
        #   client.create(:apex_page, :full_name => 'TestPage')
        def create(type, metadata={})
          type = type.to_s.camelize
          response = request(:create) do |soap|
            soap.body = {
              :metadata => prepare(metadata)
            }.merge(attributes!(type))
          end
          Hashie::Mash.new(response.body).create_response.result
        end

        # Public: Delete metadata
        #
        # Examples
        #
        #   client.delete(:apex_component, 'Component')
        def delete(type, *args)
          type = type.to_s.camelize
          metadata = args.map { |full_name| {:full_name => full_name} }
          response = request(:delete) do |soap|
            soap.body = {
              :metadata => metadata
            }.merge(attributes!(type))
          end
          Hashie::Mash.new(response.body).delete_response.result
        end

        # Public: Update metadata
        #
        # Examples
        #
        #   client.update(:apex_page, 'OldPage', :full_name => 'NewPage')
        def update(type, current_name, metadata={})
          type = type.to_s.camelize
          response = request(:update) do |soap|
            soap.body = {
              :metadata => {
                :current_name => current_name,
                :metadata => prepare(metadata)
              }.merge(attributes!(type))
            }
          end
          Hashie::Mash.new(response.body).update_response.result
        end

      private

        def attributes!(type)
          {:attributes! => { 'ins0:metadata' => { 'xsi:type' => "ins0:#{type}" } }}
        end

        # Internal: Prepare metadata by base64 encoding any content keys.
        def prepare(metadata)
          metadata = [metadata] unless metadata.is_a? Array
          metadata.each { |m| encode_content(m) }
          metadata
        end

        # Internal: Base64 encodes any :content keys.
        def encode_content(metadata)
          metadata[:content] = Base64.encode64(metadata[:content]) if metadata.has_key?(:content)
        end
        
      end
    end
  end
end
