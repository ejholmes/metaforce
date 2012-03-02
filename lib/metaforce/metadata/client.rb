require 'metaforce/manifest'
require 'savon'
require 'zip/zip'
require 'base64'
require 'ostruct'

module Metaforce
  module Metadata
    class Client
      DEPLOY_ZIP = 'deploy.zip' # :nodoc:
      RETRIEVE_ZIP = 'retrieve.zip' # :nodoc:

      # Performs a login and sets the session_id and metadata_server_url.
      #
      # +options+ should be hash containing the +:username+, +:password+ and
      # +:security_token+ keys.
      #
      # == Examples
      #
      #   Metaforce::Metadata::Client.new :username => "username",
      #     :password => "password",
      #     :security_token => "security token"
      def initialize(options=nil)
        @session = Services::Client.new(options).session
        @client = Savon::Client.new File.expand_path("../../../../wsdl/#{Metaforce.configuration.api_version}/metadata.xml", __FILE__) do |wsdl|
          wsdl.endpoint = @session[:metadata_server_url]
        end
        @client.http.auth.ssl.verify_mode = :none
        @header = {
            "ins0:SessionHeader" => {
              "ins0:sessionId" => @session[:session_id]
            }
        }
      end

      # Specify an array of component types to list.
      #
      # == Examples
      #
      #   # Get a list of apex classes on the server and output the names of each
      #   client.list(:type => "ApexClass").collect { |t| t[:full_name] }
      #   #=> ["al__SObjectPaginatorListenerForTesting", "al__IndexOutOfBoundsException", ... ]
      #
      #   # Get a list of apex components and apex classes
      #   client.list([{ :type => "CustomObject" }, { :type => "ApexComponent" }])
      #   #=> ["ContractContactRole", "Solution", "Invoice_Statements__c", ... ]
      def list(queries=[])
        unless queries.is_a?(Array)
          queries = [ queries ]
        end
        response = @client.request(:list_metadata) do |soap|
          soap.header = @header
          soap.body = {
            :queries => queries
          }
        end
        response.body[:list_metadata_response][:result]
      end

      # Defines some helper methods for listing metadata types
      #
      # == Examples
      #  
      #   # List the names of all apex classes
      #   client.list_apex_classes.collect { |t| t[:full_name] }
      #   #=> ["al__SObjectPaginatorListenerForTesting", "al__IndexOutOfBoundsException", ... ]
      #
      #   # List the names of all custom objects
      #   client.list_custom_objects.collect { |t| t[:full_name] }
      #   #=> ["Asset", "estore__Ida_Menu_Item__c", "SfoMatchHistoryItem", ... ]
      METADATA_TYPES.each do |type, value|
        define_method("list_#{value[:plural]}".to_sym) do
          list :type => value[:name]
        end
      end

      # Describe the organization's metadata and cache the response
      #
      # == Examples
      #
      #   # List the names of all metedata types
      #   client.describe[:metadata_objects].collect { |t| t[:xml_name] }
      #   #=> ["CustomLabels", "StaticResource", "Scontrol", "ApexComponent", ... ]
      def describe(version=nil)
        @describe ||= describe!(version)
      end

      # See +describe+
      def describe!(version=nil)
        response = @client.request(:describe_metadata) do |soap|
          soap.header = @header
          soap.body = { :api_version => version } unless version.nil?
        end
        @describe = response.body[:describe_metadata_response][:result]
      end

      # Checks the status of an async result. If type is +:retrieve+ or +:deploy+,
      # it returns the RetrieveResult or DeployResult, respectively
      #
      # == Examples
      # 
      #   client.status('04sU0000000Wx6KIAS')
      #   #=> {:done=>true, :id=>"04sU0000000Wx6KIAS", :state=>"Completed", :state_detail_last_modified_date=>#<DateTime: 2012-02-03T18:30:38+00:00 ((2455961j,66638s,0n),+0s,2299161j)>}
      def status(ids, type=nil)
        request = "check_status"
        request = "check_#{type.to_s}_status" unless type.nil?
        ids = [ ids ] unless ids.is_a?(Array)

        Metaforce.log("Polling server for status on #{ids.join(', ')}")

        response = @client.request(request.to_sym) do |soap|
          soap.header = @header
          soap.body = {
            :ids => ids
          }
        end
        response.body["#{request}_response".to_sym][:result]
      end

      # Returns true if the deployment with id id is done, false otherwise
      #
      # == Examples
      #
      #   client.done?('04sU0000000Wx6KIAS')
      #   #=> true
      def done?(id)
        self.status(id)[:done] || false
      end

      # Deploys +path+ to the organisation. +path+ can either be a path to
      # a directory or a path to a zip file.
      #
      # +options+ can contain any of the following keys:
      #
      # +options+: 
      # See http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_deploy.htm#deploy_options
      # for a list of _deploy_options_. Options should be convereted from
      # camelCase to an :underscored_symbol.
      #
      # == Examples
      # 
      #   deploy = client.deploy File.expand_path("myeclipseproj")
      #   #=> #<Metaforce::Transaction:0x1159bd0 @id='04sU0000000Wx6KIAS' @type=:deploy>
      #
      #   deploy.done?
      #   #=> true
      #
      #   deploy.status[:state]
      #   #=> "Completed"
      def deploy(path, options={})
        if path.is_a?(String)
          filename = File.join(File.dirname(path), DEPLOY_ZIP)
          zip_contents = create_deploy_file(filename, path)
        elsif path.is_a?(File)
          zip_contents = Base64.encode64(path.read)
        end

        Metaforce.log('Executing deploy')

        response = @client.request(:deploy) do |soap|
          soap.header = @header
          soap.body = {
            :zip_file => zip_contents,
            :deploy_options => options[:options] || {}
          }
        end
        Transaction.deployment self, response[:deploy_response][:result][:id]
      end

      # Performs a retrieve
      #
      # See http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_retrieve_request.htm
      # for a list of _retrieve_request_ options. Options should be convereted from
      # camelCase to an :underscored_symbol. _retrieve_request_ options should
      # be specified under the +:options+ key in options.
      def retrieve(options={})
        Metaforce.log('Executing retrieve')

        response = @client.request(:retrieve) do |soap|
          soap.header = @header
          soap.body = {
            :retrieve_request => options[:options] || {}
          }
        end
        Transaction.retrieval self, response[:retrieve_response][:result][:id]
      end

      # Retrieves files specified in the manifest file (package.xml). Specificy any extra options in +options[:options]+.
      #
      # == Examples
      #
      #   retrieve = client.retrieve_unpackaged File.expand_path("spec/fixtures/sample/src/package.xml")
      #   #=> #<Metaforce::Transaction:0x1159bd0 @id='04sU0000000Wx6KIAS' @type=:retrieve>
      def retrieve_unpackaged(manifest, options={})
        if manifest.is_a?(Metaforce::Manifest)
          package = manifest.to_package
        elsif manifest.is_a?(String)
          package = Metaforce::Manifest.new(File.open(manifest).read).to_package
        end
        options[:options] = {
          :api_version => Metaforce.configuration.api_version,
          :single_package => true,
          :unpackaged => {
            :types => package
          }
        }.merge(options[:options] || {})
        retrieve(options)
      end

    private
    
      # Creates the deploy file, reads in the contents and returns the base64
      # encoded data
      def create_deploy_file(filename, dir)
        File.delete(filename) if File.exists?(filename)
        Zip::ZipFile.open(filename, Zip::ZipFile::CREATE) do |zip|
          Dir["#{dir}/**/**"].each do |file|
            zip.add(file.sub(dir + '/', ''), file)
          end
        end
        contents = Base64.encode64(File.open(filename, "rb").read)
        File.delete(filename)
        contents
      end

    end
  end
end
