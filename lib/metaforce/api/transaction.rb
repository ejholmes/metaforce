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

    def done?
      @done = @client.done?(@id) unless @done
      @done
    end
    alias :complete? :done?
    alias :completed? :done?

    def result
      @client.status(@id, @type)
    end
  end
end
