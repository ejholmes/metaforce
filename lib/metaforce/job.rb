module Metaforce
  class Job
    autoload :Deploy,   'metaforce/job/deploy'
    autoload :Retrieve, 'metaforce/job/retrieve'

    # Job id.
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

    # Public: Perform the job.
    def perform
      raise 'not implemented.'
    end

    # Public: Queries the job status from the API.
    def status
      client.status(id, status_type)
    end

    # Public: Returns true if the job has completed. 
    def done?
      status.done
    end

  private

    # Internal: The Metaforce::Metadata::Client instance.
    def client
      @client
    end

  end
end
