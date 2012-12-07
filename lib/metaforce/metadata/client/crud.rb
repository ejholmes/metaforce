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
              :metadata => metadata,
              :attributes! => { 'ins0:metadata' => { 'xsi:type' => "wsdl:#{type}" } }
            }
          end
          Hashie::Mash.new(response.body).create_response.result
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
                :metadata => metadata,
                :attributes! => { :metadata => { 'xsi:type' => "wsdl:#{type}" } }
              }
            }
          end
          Hashie::Mash.new(response.body).update_response.result
        end
        
      end
    end
  end
end
