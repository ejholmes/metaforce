module Metaforce
  class Job
    attr_reader :id

    class << self
      def status_type(type)
        define_method :status_type do
          type
        end
      end
    end

    def initialize(client)
      @client = client
    end

    def perform
      raise 'not implemented.'
    end

    def status
      client.status(id, status_type)
    end

    def done?
      status.done
    end

  private

    def client
      @client
    end

  end
end

require 'metaforce/job/deploy'
require 'metaforce/job/retrieve'
