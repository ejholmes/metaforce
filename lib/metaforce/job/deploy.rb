module Metaforce
  class Job::Deploy < Job
    attr_reader :id

    def initialize(client, path, options)
      super(client)
      @path, @options = path, options
    end

    def perform
      @id = client.deploy(zip_file, @options)
    end
  end
end
