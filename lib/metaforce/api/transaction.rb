module Metaforce

  # Convenience class for deployment/retrieval results
  class Transaction
    attr_reader :id
    attr_reader :type

    def initialize(id, client, type)
      @id = id
      @client = client
      @type = type
    end

    # Returns true if the transaction has completed, false otherwise
    def done?
      @done = @client.done?(@id) unless @done
      @done
    end
    alias :complete? :done?
    alias :completed? :done?
    
    # Enters a loop until .done? returns true
    def wait_until_done
      wait_time = 1
      until self.done?
        sleep(wait_time)
        wait_time *= 2
      end
    end

    # Returns the deploy or retrieve result
    def result
      raise "Request is not complete! Be sure to call .done? first!" unless @done
      @result = @client.status(@id, @type) if @result.nil?
      @result
    end
  end
end
