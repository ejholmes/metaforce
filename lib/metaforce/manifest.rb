require 'nokogiri'
require 'active_support/core_ext'

module Metaforce
  class Manifest < Hash

    # Public: Initializes a new instance of a manifest (package.xml) file.
    #
    # It can either take a hash:
    #   {
    #     :apex_class => [
    #       "TestController",
    #       "TestClass"
    #     ],
    #     :apex_component => [
    #       "SiteLogin"
    #     ]
    #   }
    #
    # Or an xml string containing the contents of a packge.xml file:
    #  <?xml version="1.0"?>
    #  <Package xmlns="http://soap.sforce.com/2006/04/metadata">
    #    <types>
    #      <members>TestClass</members>
    #      <members>AnotherClass</members>
    #      <name>ApexClass</name>
    #    </types>
    #    <types>
    #      <members>Component</members>
    #      <name>ApexComponent</name>
    #    </types>
    #    <types>
    #      <members>Assets</members>
    #      <name>StaticResource</name>
    #    </types>
    #    <version>23.0</version>
    #  </Package>
    #
    def initialize(components={})
      self.replace Hash.new { |h,k| h[k] = [] }
      if components.is_a?(Hash)
        self.merge!(components)
      elsif components.is_a?(String)
        self.parse(components)
      end
    end

    # Public: Returns a string containing a package.xml file
    #
    #  <?xml version="1.0"?>
    #  <Package xmlns="http://soap.sforce.com/2006/04/metadata">
    #    <types>
    #      <members>TestClass</members>
    #      <members>AnotherClass</members>
    #      <name>ApexClass</name>
    #    </types>
    #    <types>
    #      <members>Component</members>
    #      <name>ApexComponent</name>
    #    </types>
    #    <types>
    #      <members>Assets</members>
    #      <name>StaticResource</name>
    #    </types>
    #    <version>23.0</version>
    #  </Package>
    def to_xml
      xml_builder = Nokogiri::XML::Builder.new do |xml|
        xml.Package('xmlns' => 'http://soap.sforce.com/2006/04/metadata') {
          self.each do |key, members|
            xml.types {
              members.each do |member|
                xml.members member
              end
              xml.name key.to_s.camelize
            }
          end
          xml.version Metaforce.configuration.api_version
        }
      end
      xml_builder.to_xml
    end

    # Public: Converts the manifest into a format that can be used by the
    # metadata api.
    def to_package
      self.map do |type, members|
        { :members => members, :name => type.to_s.camelize }
      end
    end

    # Public: Parses a package.xml file
    def parse(file)
      document = Nokogiri::XML(file).remove_namespaces!
      document.xpath('//types').each do |type|
        name = type.xpath('name').first.content
        key = name.underscore.to_sym
        type.xpath('members').each do |member|
          self[key] << member.content
        end
      end
      self
    end

  end
end
