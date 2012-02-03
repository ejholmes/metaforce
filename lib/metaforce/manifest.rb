require 'nokogiri'
require 'metaforce/types'

module Metaforce
  class Manifest
    SFDC_API_VERSION = "23.0"

    # Initializes a new instance of a manifest (package.xml) file.
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
      # Map component type => folder
      if components.is_a?(Hash)
        @components = components
      elsif components.is_a?(String)
        @components = {}
        self.parse(components)
      end
    end

    # Adds components to the package
    #
    #  manifest.add :apex_class, 'SomeClass'
    def add(type, members=nil)
      unless members.nil?
        @components[type] = [] if @components[type].nil?
        members = [members] if members.is_a?(String)
        members.each do |member|
          member = member.gsub(/.*\//, '').gsub(/\..*/, '');
          @components[type].push(member)
        end
      end
      self
    end

    # Removes components from the package
    #
    #  manifest.remove :apex_class, 'SomeClass'
    def remove(type, members=nil)
      unless members.nil?
        members = [members] if members.is_a?(String)
        members.each do |member|
          member = member.gsub(/.*\//, '').gsub(/\..*/, '');
          @components[type].delete(member)
        end
      end
      if @components[type].empty?
        @components.delete(type)
      end
      self
    end

    # Filters the components based on a list of files
    #
    #  manifest.only(['classes/SomeClass'])
    def only(files)
      components = @components
      @components = {}
      files.each do |file|
        parts = file.split('/').last(2)
        folder = parts[0]
        file = parts[1].gsub(/.*\//, '').gsub(/\..*/, '')
        components.each_key do |type|
          if component_folder(type) =~ /#{folder}/i
            unless components[type].index(file).nil?
              self.add(type, file);
            end
          end
        end
      end
      self
    end

    # Returns the components name
    def component_name(key) # :nodoc:
      METADATA_TYPES[key][:name]
    end

    # Returns the components folder
    def component_folder(key) # :nodoc:
      METADATA_TYPES[key][:folder]
    end

    # Returns a key for the component name
    def component_key(name) # :nodoc:
      METADATA_TYPES.each do |key, component|
        return key if component[:name] == name
      end
    end

    # Returns a string containing a package.xml file
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
        xml.Package("xmlns" => "http://soap.sforce.com/2006/04/metadata") {
          @components.each do |key, members|
            xml.types {
              members.each do |member|
                xml.members member
              end
              xml.name component_name(key)
            }
          end
          xml.version SFDC_API_VERSION
        }
      end
      xml_builder.to_xml
    end

    # Returns the underlying hash structure
    #
    #   {
    #     :apex_class => [
    #       "TestController",
    #       "TestClass"
    #     ],
    #     :apex_component => [
    #       "SiteLogin"
    #     ]
    #   }
    def to_hash
      @components
    end

    # Used internall my Metaforce::Metadata::Client
    def to_package
      components = []
      @components.each do |type, members|
        name = component_name(type)
        components.push :members => members, :name => name
      end
      components
    end

    # Parses a package.xml file
    def parse(file)
      document = Nokogiri::XML(file).remove_namespaces!
      document.xpath('//types').each do |type|
        name = type.xpath('name').first.content
        key = component_key(name);
        type.xpath('members').each do |member|
          if @components[key].is_a?(Array)
            @components[key].push(member.content)
          else
            @components[key] = [member.content]
          end
        end
      end
      self
    end

  end
end
