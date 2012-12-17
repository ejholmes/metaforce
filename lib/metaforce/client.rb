module Metaforce
  class Client
    def initialize(options)
      @options = options
    end

    # Public: Used to interact with the Metadata API.
    def metadata
      @metadata ||= Metadata::Client.new(@options)
    end

    # Public: Used to interact with the Services API.
    def services
      @services ||= Services::Client.new(@options)
    end

    # Public: Deploy code to Salesforce.
    #
    # path    - A path to a zip file, or a directory to deploy.
    # options - Deploy options.
    #
    # Examples
    #
    #   client.deploy(File.expand_path('./src'))
    def deploy(path, options={})
      Job::Deploy.new(metadata, path, options)
    end

    def retrieve(options={})
      Job::Retrieve.new(metadata, options)
    end

    # Public: Retrieves files specified in the manifest file (A package.xml
    # file).
    def retrieve_unpackaged(manifest, options={})
      package = if manifest.is_a?(Metaforce::Manifest)
        manifest
      elsif manifest.is_a?(String)
        Metaforce::Manifest.new(File.open(manifest).read)
      end
      options = {
        :api_version    => Metaforce.configuration.api_version,
        :single_package => true,
        :unpackaged     => { :types => package.to_package }
      }.merge(options)
      retrieve(options)
    end
  end
end
