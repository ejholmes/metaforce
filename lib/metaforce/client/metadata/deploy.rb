module Metaforce
  class Client
    module Metadata
      module Deploy

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
        
      end
    end
  end
end
