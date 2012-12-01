module Metaforce
  module Metadata
    class Client < Metaforce::Client
      endpoint :metadata_server_url
      wsdl Metaforce.configuration.metadata_wsdl

      # Public: Specify an array of component types to list.
      #
      # Examples
      #
      #   # Get a list of apex classes on the server and output the names of each
      #   client.list_metadata('ApexClass').collect { |t| t.full_name }
      #   #=> ["al__SObjectPaginatorListenerForTesting", "al__IndexOutOfBoundsException", ... ]
      #
      #   # Get a list of apex components and apex classes
      #   client.list_metadata('CustomObject', 'ApexComponent')
      #   #=> ["ContractContactRole", "Solution", "Invoice_Statements__c", ... ]
      def list_metadata(*args)
        queries = args.map(&:to_s).map(&:camelize).map { |t| {:type => t} }
        response = request(:list_metadata) do |soap|
          soap.body = { :queries => queries }
        end
        Hashie::Mash.new(response.body).list_metadata_response.result
      end

      # Public: Describe the organization's metadata.
      #
      # version - API version (default: latest).
      #
      # Examples
      #
      #   # List the names of all metadata types
      #   client.describe.metadata_objects.collect { |t| t.xml_name }
      #   #=> ["CustomLabels", "StaticResource", "Scontrol", "ApexComponent", ... ]
      def describe(version=nil)
        response = request(:describe_metadata) do |soap|
          soap.body = { :api_version => version } unless version.nil?
        end
        Hashie::Mash.new(response.body).describe_metadata_response.result
      end

      # Public: Checks the status of an async result.
      #
      # ids  - A list of ids to check.
      # type - either :deploy or :retrieve
      #
      # Examples
      # 
      #   client.status('04sU0000000Wx6KIAS')
      #   #=> {:done=>true, :id=>"04sU0000000Wx6KIAS", :state=>"Completed", ...}
      def status(ids, type=nil)
        method = :check_status
        method = :"check_#{type}_status" if type
        ids = [ids] unless ids.respond_to?(:each)
        response = request(method) do |soap|
          soap.body = { :ids => ids }
        end
        Hashie::Mash.new(response.body)[:"#{method}_response"].result
      end

      # Public: Deploy code to Salesforce.
      #
      # zip_file - The base64 encoded contents of the zip file.
      # options  - Hash of DeployOptions.
      # 
      # Returns the id of the AsyncResult.
      def deploy(zip_file, options={})
        response = request(:deploy) do |soap|
          soap.body = {
            :zip_file       => zip_file,
            :deploy_options => options
          }
        end
        Hashie::Mash.new(response.body).deploy_response.result.id
      end
    end
  end
end
