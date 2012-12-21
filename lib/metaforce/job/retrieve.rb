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
      client.status(id, :retrieve)
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
    # Examples
    #
    #   job.extract_to('./path')
    #   # => #<Metaforce::Job::Retrieve @id='1234'>
    #
    # Returns self.
    def extract_to(destination)
      return on_complete { |job| job.extract_to(destination) } unless @id
      Zip::ZipFile.open(tmp_zip_file) do |zip|
        zip.each do |f|
          path = File.join(destination, f.name)
          FileUtils.mkdir_p(File.dirname(path))
          zip.extract(f, path) { true }
        end
      end
      self
    end

  private

    # Internal: Writes the zip file content to a temporary location so it can
    # be extracted.
    def tmp_zip_file
      @tmp_zip_file ||= begin
        file = Tempfile.new('retrieve')
        file.write(zip_file)
        path = file.path
        file.close
        path
      end
    end

  end
end
