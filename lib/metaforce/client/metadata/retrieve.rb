module Metaforce
  class Client
    module Metadata
      module Retrieve
        
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
  end
end
