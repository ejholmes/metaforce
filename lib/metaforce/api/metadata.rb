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
      # _options_ should be hash containing the :username, :password and
      # :security_token keys.
      #
      #  Metaforce::Metadata::Client.new :username => "username",
      #    :password => "password",
      #    :security_token => "security token"
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

      # Specify an array of component types to list
      #
      #   [
      #     { :type => "ApexClass" },
      #     { :type => "ApexComponent" }
      #   ]
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

      # Describe the organization's metadata and cache the response
      def describe
        @describe ||= describe!
      end

      # Describe the organization's metadata
      def describe!
        response = @client.request(:describe_metadata) do |soap|
          soap.header = @header
        end
        response.body[:describe_metadata_response][:result]
      end

      # Checks the status of an async result
      #
      # If type is :retrieve or :deploy, it returns the RetrieveResult or
      # DeployResult, respectively
      def status(ids, type=nil)
        request = "check_status"
        request = "check_#{type.to_s}_status" unless type.nil?
        ids = [ ids ] unless ids.is_a?(Array)

        response = @client.request(request.to_sym) do |soap|
          soap.header = @header
          soap.body = {
            :ids => ids
          }
        end
        response.body["#{request}_response".to_sym][:result]
      end

      # Returns true if the deployment with id id is done, false otherwise
      def done?(id)
        self.status(id)[:done]
      end

      # Deploys _dir_ to the organisation
      #
      # See http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_deploy.htm#deploy_options
      # for a list of _deploy_options_. Options should be convereted from
      # camelCase to an :underscored_symbol.
      def deploy(dir, deploy_options={})
        if dir.is_a?(String)
          filename = File.join(File.dirname(dir), DEPLOY_ZIP)
          zip_contents = create_deploy_file(filename, dir)
        elsif dir.is_a?(File)
          zip_contents = Base64.encode64(dir.read)
        end

        response = @client.request(:deploy) do |soap|
          soap.header = @header
          soap.body = {
            :zip_file => zip_contents,
            :deploy_options => deploy_options
          }
        end
        Transaction.deployment self, response[:deploy_response][:result][:id]
      end

      # Performs a retrieve
      #
      # See http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_retrieve_request.htm
      # for a list of _retrieve_request_ options. Options should be convereted from
      # camelCase to an :underscored_symbol.
      def retrieve(retrieve_request={})
        response = @client.request(:retrieve) do |soap|
          soap.header = @header
          soap.body = {
            :retrieve_request => retrieve_request
          }
        end
        Transaction.retrieval self, response[:retrieve_response][:result][:id]
      end

      # Retrieves files specified in the manifest file (package.xml)
      #
      # Specificy any extra _retrieve_request_ options in _extra_.
      def retrieve_unpackaged(manifest, extra=nil)
        if manifest.is_a?(Metaforce::Manifest)
          package = manifest.to_package
        elsif manifest.is_a?(String)
          package = Metaforce::Manifest.new(File.open(manifest).read).to_package
        end
        retrieve_request = { 
          :api_version => Metaforce.configuration.api_version,
          :single_package => true,
          :unpackaged => {
            :types => package
          }
        }
        retrieve_request.merge!(extra) if extra.is_a?(Hash)
        retrieve(retrieve_request)
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
