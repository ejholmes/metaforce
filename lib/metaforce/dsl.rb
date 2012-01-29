require 'tempfile'
require 'zip/zip'

module Metaforce
  module DSL
    module Metadata
      def login(options)
        @client = Metaforce::Metadata::Client.new options
      end

      # Deploy the contents of _dir_ to the target organization
      def deploy(dir, options={})
        deployment = @client.deploy dir, options
        result = deployment.result :wait_until_done => true
        raise "Deploy failed." if !result[:success]
        yield result if block_given?
      end
      
      # Retrieve the metadata specified in the manifest file. If _options_
      # contains a key _:to_, the resulting zip file that is retrieved is
      # unzipped to the directory specified.
      def retrieve(manifest, options={})
        retrieval = @client.retrieve_unpackaged manifest
        result = retrieval.result :wait_until_done => true
        zip_contents = retrieval.zip_file
        unzip(zip_contents, options[:to]) if options.has_key?(:to)
        yield result, zip_contents if block_given?
      end

      # Unzips _zip_contents_ to _destination_
      def unzip(zip_contents, destination)
        file = Tempfile.new("retrieve")
        file.write(zip_contents)
        path = file.path
        file.close

        Zip::ZipFile.open(path) do |zip_file|
          zip_file.each do |f|
            path = File.join(destination, f.name)
            FileUtils.mkdir_p(File.dirname(path))
            zip_file.extract(f, path)
          end
        end
      end
    end
  end
end
