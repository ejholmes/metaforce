module Metaforce
  class Job::Deploy < Job
    attr_reader :id

    def initialize(client, path, options={})
      super(client)
      @path, @options = path, options
    end

    def perform
      @id = client.deploy(payload, @options)
    end

    # Public: Base64 encodes the contents of the zip file.
    def payload
      Base64.encode64(File.open(@path, 'rb').read)
    end
  end
end
