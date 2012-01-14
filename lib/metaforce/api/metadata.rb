require 'savon'
require 'zip/zip'
require 'base64'

module Metaforce
  module Metadata
    class Client
      DEPLOY_ZIP = 'deploy.zip'
      RETRIEVE_ZIP = 'retrieve.zip'

      def initialize(options=nil)
        @session = Services::Client.new(options).session
        @client = Savon::Client.new File.expand_path("../../../../wsdl/#{Metaforce.configuration.api_version}/metadata.xml", __FILE__) do |wsdl|
          wsdl.endpoint = @session[:metadata_server_url]
        end
        @header = {
            "ins0:SessionHeader" => {
              "ins0:sessionId" => @session[:session_id]
            }
        }
      end

      # Specify an array of component types to list
      #
      # example:
      # [
      #   { :type => "ApexClass" },
      #   { :type => "ApexComponent" }
      # ]
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

      # Describe the organization's metadata
      def describe
        response = @client.request(:describe_metadata) do |soap|
          soap.header = @header
        end
        response.body[:describe_metadata_response][:result]
      end

      # Checks the status of an async result
      def status(ids)
        unless ids.is_a?(Array)
          ids = [ ids ]
        end
        response = @client.request(:check_status) do |soap|
          soap.header = @header
          soap.body = {
            :ids => ids
          }
        end
        response.body[:check_status_response][:result]
      end

      # Returns true if the deployment with id id is done, false otherwise
      def is_done?(id)
        self.status(id)[:done]
      end

      # Deploys dir to the organisation
      def deploy(dir, options={})
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
            :deploy_options => options
          }
        end
        response[:deploy_response][:result][:id]
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
