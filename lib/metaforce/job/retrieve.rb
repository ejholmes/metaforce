module Metaforce
  class Job::Retrieve < Job

    # Public: Instantiate a new retrieve job.
    #
    # Examples
    #
    #   job = Metaforce::Job::Retrieve.new(client)
    #   # => #<Metaforce::Job::Retrieve @id=nil>
    #
    # Returns self.
    def initialize(client, options={})
      super(client)
      @options = options
    end

    # Public: Perform the job.
    #
    # Examples
    #
    #   job = Metaforce::Job::Retrieve.new(client)
    #   job.perform
    #   # => #<Metaforce::Job::Retrieve @id='1234'>
    #
    # Returns self.
    def perform
      @id = client._retrieve(@options).id
      super
    end

    # Public: Get the detailed status of the retrieve.
    #
    # Examples
    #
    #   job.result
    #   # => { :id => '1234', :zip_file => '<base64 encoded content>', ... }
    #
    # Returns the RetrieveResult (http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_retrieveresult.htm).
    def result
      @result ||= client.status(id, :retrieve)
    end

    # Public: Decodes the content of the returned zip file.
    #
    # Examples
    #
    #   job.zip_file
    #   # => '<binary content>'
    #
    # Returns the decoded content.
    def zip_file
      Base64.decode64(result.zip_file)
    end

    # Public: Unzips the returned zip file to the location.
    #
    # destination - Path to extract the contents to.
    #
    # Examples
    #
    #   job.extract_to('./path')
    #   # => #<Metaforce::Job::Retrieve @id='1234'>
    #
    # Returns self.
    def extract_to(destination)
      return on_complete { |job| job.extract_to(destination) } unless started?
      with_tmp_zip_file do |file|
        unzip(file, destination)
      end
      self
    end

  private

    # Internal: Unzips source to destination.
    def unzip(source, destination)
      Zip::File.open(source) do |zip|
        zip.each do |f|
          path = File.join(destination, f.name)
          FileUtils.mkdir_p(File.dirname(path))
          zip.extract(f, path) { true }
        end
      end
    end

    # Internal: Writes the zip file content to a temporary location so it can
    # be extracted.
    def with_tmp_zip_file
      file = Tempfile.new('retrieve')
      begin
        file.binmode
        file.write(zip_file)
        file.rewind
        yield file
      ensure
        file.close
        file.unlink
      end
    end

  end
end
