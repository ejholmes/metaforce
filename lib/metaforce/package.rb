require 'nokogiri'

module Metaforce
  class Package
    SFDC_API_VERSION = "23.0"

    # example format
    # {
    #   :apex_class => [
    #     "TestController",
    #     "TestClass"
    #   ],
    #   :apex_component => [
    #     "SiteLogin"
    #   ]
    # }
    def initialize(components={})
      # Map component type => folder
      if components.class == Hash
        @components = components
      elsif components.class == String
        @components = {}
        self.parse(components)
      end
    end

    # Adds components to the package
    def add(type, members=nil)
      unless members.nil?
        @components[type] = [] if @components[type].nil?
        members = [members] if members.class == String
        members.each do |member|
          member = member.gsub(/.*\//, '').gsub(/\..*/, '');
          @components[type].push(member)
        end
      end
      self
    end

    # Removes components from the package
    def remove(type, members=nil)
      unless members.nil?
        members = [members] if members.class == String
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
    def component_name(key)
      COMPONENT_TYPE_MAP[key][:name]
    end

    # Returns the components folder
    def component_folder(key)
      COMPONENT_TYPE_MAP[key][:folder]
    end

    # Returns a key for the component name
    def component_key(name)
      COMPONENT_TYPE_MAP.each do |key, component|
        return key if component[:name] == name
      end
    end

    # Returns a string containing a package.xml file
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

    def to_hash
      @components
    end

    # Parses a package.xml file
    def parse(file)
      document = Nokogiri::XML(file).remove_namespaces!
      document.xpath('//types').each do |type|
        name = type.xpath('name').first.content
        key = component_key(name);
        type.xpath('members').each do |member|
          if @components[key].class == Array
            @components[key].push(member.content)
          else
            @components[key] = [member.content]
          end
        end
      end
      self
    end

    COMPONENT_TYPE_MAP = {
      :action_override => {
        :name => "ActionOverride",
        :folder => "objects"
      },
      :analytics_snapshot => {
        :name => "AnalyticsSnapshot",
        :folder => "analyticsnapshots"
      },
      :apex_class => {
        :name => "ApexClass",
        :folder => "classes"
      },
      :article_type => {
        :name => "ArticleType",
        :folder => "objects"
      },
      :apex_component => {
        :name => "ApexComponent",
        :folder => "components"
      },
      :apex_page => {
        :name => "ApexPage",
        :folder => "pages"
      },
      :apex_trigger => {
        :name => "ApexTrigger",
        :folder => "triggers"
      },
      :business_process => {
        :name => "BusinessProcess",
        :folder => "objects"
      },
      :custom_application => {
        :name => "CustomApplication",
        :folder => "applications"
      },
      :custom_field => {
        :name => "CustomField",
        :folder => "objects"
      },
      :custom_labels => {
        :name => "CustomLabels",
        :folder => "labels"
      },
      :custom_object => {
        :name => "CustomObject",
        :folder => "objects"
      },
      :custom_object_translation => {
        :name => "CustomObjectTranslation",
        :folder => "objectTranslations"
      },
      :custom_page_web_link => {
        :name => "CustomPageWebLink",
        :folder => "weblinks"
      },
      :custom_site => {
        :name => "CustomSite",
        :folder => "sites"
      },
      :custom_tab => {
        :name => "CustomTab",
        :folder => "tabs"
      },
      :dashboard => {
        :name => "Dashboard",
        :folder => "dashboards"
      },
      :data_category_group => {
        :name => "DataCategoryGroup",
        :folder => "datacategorygroups"
      },
      :document => {
        :name => "Document",
        :folder => "document"
      },
      :email_template => {
        :name => "EmailTemplate",
        :folder => "email"
      },
      :entitlement_template => {
        :name => "EntitlementTemplate",
        :folder => "entitlementTemplates"
      },
      :field_set => {
        :name => "FieldSet",
        :folder => "objects"
      },
      :home_page_component => {
        :name => "HomePageComponent",
        :folder => "homePageComponents"
      },
      :layout => {
        :name => "Layout",
        :folder => "layouts"
      },
      :letterhead => {
        :name => "Letterhead",
        :folder => "letterhead"
      },
      :list_view => {
        :name => "ListView",
        :folder => "objects"
      },
      :named_filter => {
        :name => "NamedFilter",
        :folder => "objects"
      },
      :permission_set => {
        :name => "PermissionSet",
        :folder => "permissionsets"
      },
      :portal => {
        :name => "Portal",
        :folder => "portals"
      },
      :profile => {
        :name => "Profile",
        :folder => "profiles"
      },
      :record_type => {
        :name => "RecordType",
        :folder => "objects"
      },
      :remote_site_setting => {
        :name => "RemoteSiteSetting",
        :folder => "remoteSiteSettings"
      },
      :report => {
        :name => "Report",
        :folder => "reports"
      },
      :report_type => {
        :name => "ReportType",
        :folder => "reportTypes"
      },
      :scontroler => {
        :name => "Scontroler",
        :folder => "scontrols"
      },
      :sharing_reason => {
        :name => "SharingReason",
        :folder => "objects"
      },
      :sharing_recalculation => {
        :name => "SharingRecalculation",
        :folder => "objects"
      },
      :static_resource => {
        :name => "StaticResource",
        :folder => "staticResources"
      },
      :translations => {
        :name => "Translations",
        :folder => "translations"
      },
      :validation_rule => {
        :name => "ValidationRule",
        :folder => "objects"
      },
      :weblink => {
        :name => "Weblink",
        :folder => "objects"
      },
      :workflow => {
        :name => "Workflow",
        :folder => "workflows"
      }
    }
  end
end
