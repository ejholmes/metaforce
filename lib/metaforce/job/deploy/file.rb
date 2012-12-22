module Metaforce
  class Job::Deploy::File < Job::Deploy

    # Public: Instantiate a new deploy file job.
    #
    # Examples
    #
    #   job = Metaforce::Job::Deploy.new(client, './src', './src/classes/TestClass.cls')
    #   # => #<Metaforce::Job::Deploy @id=nil>
    #
    # Returns self.
    def initialize(client, path, files, options={})
      super(client, path, options)
      @files = files
    end

  private

    # Internal: Creates a zip file with the contents of the directory.
    def zip_file
      path = Dir.mktmpdir
      ::File.join(path, 'deploy.zip').tap do |path|
        Zip::ZipFile.open(path, Zip::ZipFile::CREATE) do |zip|
          Dir["#{@path}/**/**"].each do |file|
            relative = file.sub("#{::File.dirname(@path)}/", '')
            zip.add(relative, file) if @files.include? relative
          end
        end
      end
    end

  end
end
