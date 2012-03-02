require 'base64'

module Metaforce

  # Convenience class for deployment/retrieval results
  class Transaction
    # The Salesforce ID for this task
    attr_reader :id
    # The type of transaction (e.g. _:deploy_, _:retrieve_)
    attr_reader :type

    def initialize(client, id, type=nil)
      @client = client
      @id     = id
      @type   = type
    end

    # Creates a new transaction and sets type to +:deploy+.
    def self.deployment(client, id)
      self.new client, id, :deploy
    end

    # Creates a new transaction and sets type to +:retrieve+.
    def self.retrieval(client, id)
      self.new client, id, :retrieve
    end

    # Wrapper for <tt>Client.status</tt>.
    def status
      @status = @client.status(@id)
    end

    # Wrapper for <tt>Client.done?</tt>.
    def done?
      @done = @client.done?(@id) unless @done
      @done
    end
    alias :complete? :done?
    alias :completed? :done?

    # Returns the decoded content of the returned zip file.
    def zip_file
      raise 'Request was not a retrieve.' unless @type == :retrieve
      Base64.decode64(@result[:zip_file])
    end

    # Unzips the returned zip file to +destination+.
    def unzip(destination)
      zip = zip_file
      file = Tempfile.new('retrieve')
      file.write(zip)
      path = file.path
      file.close

      Zip::ZipFile.open(path) do |zip|
        zip.each do |f|
          path = File.join(destination, f.name)
          FileUtils.mkdir_p(File.dirname(path))
          zip.extract(f, path) { true }
        end
      end
    end
    
    # Returns the deploy or retrieve result
    def result(options={})
      self.wait_until_done if (options[:wait_until_done] || Metaforce.configuration.wait_until_done)
      raise 'Request has not completed.' unless @done
      @result = @client.status(@id, @type) if @result.nil?
      raise SalesforceError, @result[:message] if @result[:state] == "Error"
      @result
    end

    # Enters a loop until .done? returns true
    def wait_until_done
      max_wait = 30
      wait_time = 1
      until self.done?
        sleep(wait_time)
        if wait_time < 30
          wait_time *= 2
        else
          wait_time = max_wait
        end
      end
    end

  end
end
