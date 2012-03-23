require 'nokogiri'

module Metaforce
  module Metadata
    class MetadataFile < Hash

      # Initialize the underlying hash
      def initialize(hash, type)
        super(hash)
        @type = type
        replace(hash)
      end

      def type
        @type
      end

      # Builds a new MetadataFile object based on the template
      #
      # == Examples
      #
      #   Metaforce::Metadata::MetadataFile.template(:apex_class)
      #   #=> {:api_version=>"23.0", :status=>"Active"}
      def self.template(type)
        Metaforce::Metadata::MetadataFile.new(TEMPLATES[type], type)
      end

      # Returns the xml representation of the underlying hash structure
      #
      # == Examples
      #
      #   f = Metaforce::Metadata::MetadataFile.template(:apex_class)
      #   f.to_xml
      #   #=> "<?xml version=\"1.0\"?>\n<ApexClass xmlns=\"http://soap.sforce.com/2006/04/metadata\">\n  <apiVersion>23.0</apiVersion>\n  <status>Active</status>\n</ApexClass>\n"
      def to_xml
        xml_builder = Nokogiri::XML::Builder.new do |xml|
          xml.send(type.to_s.camelcase, "xmlns" => "http://soap.sforce.com/2006/04/metadata") do
            self.each do |key, value|
              xml.send(key.to_s.lower_camelcase, value)
            end
          end
        end
        xml_builder.to_xml
      end

    private

      # Metadata file templates
      TEMPLATES = {
        :apex_class => {
          :api_version => Metaforce.configuration.api_version,
          :status => "Active"
        },
        :apex_component => {
          :api_version => Metaforce.configuration.api_version,
          :description => '',
          :label => ''
        },
        :apex_page => {
          :api_version => Metaforce.configuration.api_version,
          :description => '',
          :label => ''
        },
        :apex_trigger => {
          :api_version => Metaforce.configuration.api_version,
          :status => "Active"
        }
      }
    
    end
  end
end
