module Metaforce
  class Job
    def initialize(client)
      @client = client
    end

    def perform
      raise 'not implemented.'
    end

  private

    def client
      @client
    end

  end
end

require 'metaforce/job/deploy'
require 'metaforce/job/retrieve'
