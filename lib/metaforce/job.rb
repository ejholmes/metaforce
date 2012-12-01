module Metaforce
  class Job
    autoload :Deploy,   'metaforce/job/deploy'
    autoload :Retrieve, 'metaforce/job/retrieve'

    # Public: The id of the AsyncResult returned from Salesforce for
    # this job.
    attr_reader :id

    class << self
      # Internal
      def status_type(type)
        define_method :status_type do; type end
      end
    end

    def initialize(client)
      @_callbacks = Hash.new { |h,k| h[k] = [] }
      @client = client
    end

    # Public: Perform the job.
    def perform
      start_heart_beat
    end

    # Register a block to be called when the job has completed.
    def on_complete(&block)
      @_callbacks[:on_complete] << block
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

    # Internal: Starts a heart beat in a thread, which polls the job status
    # until it has completed or timed out.
    def start_heart_beat
      @heart_beat ||= Thread.new do
        loop do
          sleep 5
        end
      end
    end

    # Internal: The Metaforce::Metadata::Client instance.
    def client
      @client
    end

  end
end
