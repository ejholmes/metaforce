module Metaforce
  class Job::Deploy < Job

    # Public: Instantiate a new deploy job.
    #
    # Examples
    #
    #   job = Metaforce::Job::Deploy.new(client, './path/to/deploy')
    #   # => #<Metaforce::Job::Deploy @id=nil>
    #
    # Returns self.
    def initialize(client, path, options={})
      super(client)
      @path, @options = path, options
    end

    # Public: Perform the job.
    #
    # Examples
    #
    #   job = Metaforce::Job::Deploy.new(client, './path/to/deploy')
    #   job.perform
    #   # => #<Metaforce::Job::Deploy @id='1234'>
    #
    # Returns self.
    def perform
      @id = client._deploy(payload, @options).id
      super
    end

    # Public: Get the detailed status of the deploy.
    #
    # Examples
    #
    #   job.result
    #   # => { :id => '1234', :success => true, ... }
    #
    # Returns the DeployResult (http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_deployresult.htm).
    def result
      @result ||= client.status(id, :deploy)
    end

    # Public: Returns true if the deploy was successful.
    #
    # Examples
    #
    #   job.success?
    #   # => true
    # 
    # Returns true or false based on the DeployResult.
    def success?
      result.success
    end

  private

    # Internal: Base64 encodes the contents of the zip file.
    #
    # Examples
    #
    #   job.payload
    #   # => '<lots of base64 encoded content>'
    #
    # Returns the content of the zip file encoded to base64.
    def payload
      Base64.encode64(File.open(file, 'rb').read)
    end

    # Internal: Returns the path to the zip file.
    def file
      File.file?(@path) ? @path : zip_file
    end

    # Internal: Creates a zip file with the contents of the directory.
    def zip_file
      path = Dir.mktmpdir
      File.join(path, 'deploy.zip').tap do |path|
        Zip::File.open(path, Zip::File::CREATE) do |zip|
          Dir["#{@path}/**/**"].each do |file|
            zip.add(file.sub("#{File.dirname(@path)}/", ''), file)
          end
        end
      end
    end

  end
end
