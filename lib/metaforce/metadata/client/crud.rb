module Metaforce
  module Metadata
    class Client
      module CRUD

        # Public: Create metadata
        #
        # Examples
        #
        #   client._create(:apex_page, :full_name => 'TestPage', label: 'Test page', :content => '<apex:page>foobar</apex:page>')
        def _create(type, metadata={})
          type = type.to_s.camelize
          request :create,  message: {
                :metadata => prepare(metadata)
            }.merge(attributes!(type))
        end

        # Public: Delete metadata
        #
        # Examples
        #
        #   client._delete(:apex_component, 'Component')
        def _delete(type, *args)
          type = type.to_s.camelize
          metadata = args.map { |full_name| {:full_name => full_name} }
          request :delete,  message:  {
                :metadata => metadata
            }.merge(attributes!(type))
        end

        # Public: Update metadata
        #
        # Examples
        #
        #   client._update(:apex_page, 'OldPage', :full_name => 'TestPage', :label => 'Test page', :content => '<apex:page>hello world</apex:page>')
        def _update(type, current_name, metadata={})
          type = type.to_s.camelize
          request :update_metadata,  message: {
                :metadata => metadata
            }.merge(attributes!(type))
        end

        def create(*args)
          Job::CRUD.new(self, :_create, args)
        end

        def update(*args)
          Job::CRUD.new(self, :_update, args)
        end

        def delete(*args)
          Job::CRUD.new(self, :_delete, args)
        end

        private

        def attributes!(type)
          {:attributes! => { 'ins0:metadata' => { 'xsi:type' => "ins0:#{type}" } }}
        end

        # Internal: Prepare metadata by base64 encoding any content keys.
        def prepare(metadata)
          metadata = Array[metadata].compact.flatten
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
