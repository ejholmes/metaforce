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
          request :create do |soap|
            soap.body = {
              :metadata => prepare(metadata)
            }.merge(attributes!(type))
          end
        end

        # Public: Delete metadata
        #
        # Examples
        #
        #   client._delete(:apex_component, 'Component')
        def _delete(type, *args)
          type = type.to_s.camelize
          metadata = args.map { |full_name| {:full_name => full_name} }
          request :delete do |soap|
            soap.body = {
              :metadata => metadata
            }.merge(attributes!(type))
          end
        end

        # Public: Update metadata
        #
        # Examples
        #
        #   client._update(:apex_page, 'OldPage', :full_name => 'TestPage', :label => 'Test page', :content => '<apex:page>hello world</apex:page>')
        def _update(type, current_name, metadata={})
          type = type.to_s.camelize
          request :update do |soap|
            soap.body = {
              :metadata => {
                :current_name => current_name,
                :metadata => prepare(metadata),
                :attributes! => { :metadata => { 'xsi:type' => "ins0:#{type}" } }
              }
            }
          end
        end

        # Adds one or more new metadata components to your organization 
        # synchronously.
        #
        # Available in API version 30.0 and later.
        #
        # Example: metadataResponse = client.create_metadata(:custom_object, :full_name => 'Test__c', :label => 'Test Object', :plural_label => 'Test Objects', :name_field => [:type => 'Text', :label => 'Test Name'], :deployment_status => 'Deployed', :sharing_model => 'ReadWrite') 
        def create_metadata(type, metadata={})
          type = type.to_s.camelize
          request :create_metadata do |soap|
            soap.body = {
              :metadata => prepare(metadata)
            }.merge(attributes!(type))
          end
        end

        # Returns one or more metadata components from your organization 
        # synchronously.
        #
        # Available in API version 30.0 and later.
        #
        # Example: metadataResponse = client.read_metadata(:custom_object, ["Test__c"])
        def read_metadata(type, fullNames)
          type = type.to_s.camelize
          request :read_metadata do |soap|
            soap.body = {
                :type => type,
                :full_names => fullNames, 
            }
          end
        end

        # Updates one or more metadata components in your organization 
        # synchronously.
        #
        # Available in API version 30.0 and later.
        #
        # Example: metadataResponse = client.update_metadata(:profile, :fieldPermissions => [:field => 'Contact.'+get_namespace+'Test__c', :editable => true, :readable => true], :fullName => 'Admin')
        def update_metadata(type, metadata={})
          type = type.to_s.camelize
          request :update_metadata do |soap|
            soap.body = {
                :metadata => prepare(metadata),
            }.merge(attributes!(type))
          end
        end

        # Deletes one or more metadata components from your organization 
        # synchronously.
        #
        # Available in API version 30.0 and later.
        #
        # Example: metadataResponse = client.delete_metadata(:custom_object, ["Test__c"]) 
        def delete_metadata(type, fullNames)
          type = type.to_s.camelize
          request :delete_metadata do |soap|
            soap.body = {
                :type => type,
                :full_names => fullNames, 
            }
          end
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
