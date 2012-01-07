module Metaforce
  class Package
    def initialize
      # Map component type => folder
      @component_type_map = {
        :action_override => "objects",
        :analytics_snapshot => "analyticsnapshots",
        :apex_class => "classes",
        :article_type => "objects",
        :apex_component => "components",
        :apex_page => "pages",
        :apex_trigger => "triggers",
        :business_process => "objects",
        :custom_application => "applications",
        :custom_field => "objects",
        :custom_labels => "labels",
        :custom_object => "objects",
        :custom_object_translation => "objectTranslations",
        :custom_page_web_link => "weblinks",
        :custom_site => "sites",
        :custom_tab => "tabs",
        :dashboard => "dashboards",
        :data_category_group => "datacategorygroups",
        :document => "document",
        :email_template => "email",
        :entitlement_template => "entitlementTemplates",
        :field_set => "objects",
        :home_page_component => "homePageComponents",
        :layout => "layouts",
        :letterhead => "letterhead",
        :list_view => "objects",
        :named_filter => "objects",
        :permission_set => "permissionsets",
        :portal => "portals",
        :profile => "profiles",
        :record_type => "objects",
        :remote_site_setting => "remoteSiteSettings",
        :report => "reports",
        :report_type => "reportTypes",
        :scontroler => "scontrols",
        :sharing_reason => "objects",
        :sharing_recalculation => "objects",
        :static_resource => "staticResources",
        :translations => "translations",
        :validation_rule => "objects",
        :weblink => "objects",
        :workflow => "workflows"
      }
    end

    # Pass in an array of files to convert to a package.xml file
    #
    # Ignores any files that end in .xml
    #
    # example format for files
    # [
    #   "classes/TestController.cls",
    #   "classes/TestClass.cls",
    #   "components/SiteLogin.component"
    # ]
    def parse(files, options=nil)
      
    end

    # Pass in a hash of components to convert to a packge.xml file
    #
    # example format for components
    # {
    #   :apex_class => [
    #     "TestController",
    #     "TestClass"
    #   ],
    #   :apex_component => [
    #     "SiteLogin"
    #   ]
    # }
    def build(components)

    end
  end
end
