require 'zip/zip'

module Metaforce
  class Job::Deploy < Job
    status_type :deploy

    def initialize(client, path, options={})
      super(client)
      @path, @options = path, options
    end

    # Public: Deploy to Salesforce.
    def perform
      @id = client.deploy(payload, @options).id
      super
    end

    # Public: Base64 encodes the contents of the zip file.
    def payload
      Base64.encode64(File.open(file, 'rb').read)
    end

  private

    def file
      File.file?(@path) ? @path : zip_file
    end

    def zip_file
      path = Dir.mktmpdir
      File.join(path, 'deploy.zip').tap do |path|
        Zip::ZipFile.open(path, Zip::ZipFile::CREATE) do |zip|
          Dir["#{@path}/**/**"].each do |file|
            zip.add(file.sub("#{File.dirname(@path)}/", ''), file)
          end
        end
      end
    end

  end
end
