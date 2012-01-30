require 'tempfile'
require 'zip/zip'

module Metaforce
  module DSL
    module Metadata

      # Logs in and creates a new instance of Metaforce::Metadata::Client
      def login(options)
        @client = Metaforce::Metadata::Client.new options
        yield if block_given?
      end

      # Deploy the contents of _dir_ to the target organization
      def deploy(dir, options={})
        deployment = @client.deploy(dir, options)
        result = deployment.result(:wait_until_done => true)
        raise "Deploy failed." if !result[:success]
        yield result if block_given?
      end
      
      # Retrieve the metadata specified in the manifest file. If manifest is a
      # Hash, the underlying .retrieve method is used instead of
      # .retrieve_unpackaged.
      #
      # If _options_ # contains a key _:to_, the resulting zip
      # file that is retrieved is unzipped to the directory specified.
      def retrieve(manifest, options={})
        if manifest.is_a?(Hash)
          retrieval = @client.retrieve(manifest)
        else
          retrieval = @client.retrieve_unpackaged(manifest)
        end
        result = retrieval.result(:wait_until_done => true)
        zip_contents = retrieval.zip_file
        retrieval.unzip(options[:to]) if options.has_key?(:to)
        yield result, zip_contents if block_given?
      end

    end
  end
end
