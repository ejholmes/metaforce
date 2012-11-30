module Metaforce
  class Job::Deploy < Job
    attr_reader :id

    def intialize(client, path, options)
      @client, @path, @options = client, path, options
    end

    def perform
      @id = client.deploy(zip_file, @options)
    end

  private

    def client
      @client
    end
    
  end
end
