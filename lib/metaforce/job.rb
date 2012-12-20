require 'zip/zip'
require 'base64'

module Metaforce
  class Job
    autoload :Deploy,   'metaforce/job/deploy'
    autoload :Retrieve, 'metaforce/job/retrieve'
    autoload :CRUD,     'metaforce/job/crud'

    # Public: The id of the AsyncResult returned from Salesforce for
    # this job.
    attr_reader :id

    def initialize(client)
      @_callbacks = Hash.new { |h,k| h[k] = [] }
      @client = client
    end

    # Public: Perform the job.
    def perform
      start_heart_beat
      self
    end

    # Register a block to be called when the job has completed.
    def on_complete(&block)
      @_callbacks[:on_complete] << block
      self
    end

    def on_error(&block)
      @_callbacks[:on_error] << block
      self
    end

    # Public: Queries the job status from the API.
    def status
      client.status(id)
    end

    # Public: Returns true if the job has completed. 
    def done?
      status.done
    end

    # Public: Returns the state if the job has finished processing.
    def state
      done? && status.state
    end

    %w[Queued InProgress Completed Error].each do |state|
      define_method :"#{state.underscore}?" do; self.state == state end
    end

    def inspect
      "#<#{self.class} @id=#{@id.inspect}>"
    end

    class << self

      # Disable threading in tests.
      def mock!
        self.class_eval do
          def start_heart_beat
            loop do
              trigger_callbacks && break if completed? || error?
            end
          end
        end
      end

    end

  private
    attr_reader :client

    # Internal: Starts a heart beat in a thread, which polls the job status
    # until it has completed or timed out.
    def start_heart_beat
      Thread.abort_on_exception = true
      @heart_beat ||= Thread.new do
        delay = 1
        loop do
          sleep (delay = delay * 2)
          trigger_callbacks && Thread.stop if completed? || error?
        end
      end
    end

    def trigger_callbacks
      @_callbacks[callback_type].each do |block|
        block.call(self)
      end
      true
    end

    def callback_type
      if completed?
        :on_complete
      elsif error?
        :on_error
      end
    end

  end
end
