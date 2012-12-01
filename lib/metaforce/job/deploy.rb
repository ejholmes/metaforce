module Metaforce
  class Job::Deploy < Job
    status_type :deploy

    def initialize(client, path, options={})
      super(client)
      @path, @options = path, options
    end

    # Public: Deploy to Salesforce.
    def perform
      @id = client.deploy(payload, @options)
    end

    # Public: Base64 encodes the contents of the zip file.
    def payload
      Base64.encode64(File.open(@path, 'rb').read)
    end
  end
end
