require 'zip/zip'
require 'base64'

module Metaforce
  class Job
    DELAY_START = 1
    DELAY_MULTIPLIER = 2

    autoload :Deploy,   'metaforce/job/deploy'
    autoload :Retrieve, 'metaforce/job/retrieve'
    autoload :CRUD,     'metaforce/job/crud'

    # Public: The id of the AsyncResult returned from Salesforce for
    # this job.
    attr_reader :id

    # Public: Instantiate a new job. Doesn't actually do anything until
    # .perform is called.
    #
    # Examples
    #
    #   job = Metaforce::Job.new(client)
    #   # => #<Metaforce::Job @id=nil>
    #
    # Returns self.
    def initialize(client)
      @_callbacks = Hash.new { |h,k| h[k] = [] }
      @client = client
    end

    # Public: Perform the job.
    #
    # Examples
    #
    #   job = Metaforce::Job.new
    #   job.perform
    #   # => #<Metaforce::Job @id=nil>
    #
    # Returns self.
    def perform
      start_heart_beat
      self
    end

    # Public: Utility method to determine if .perform has been called yet.
    #
    # Returns true if @id is set, false otherwise.
    def started?
      !!@id
    end

    # Public: Register a block to be called when an event occurs.
    #
    # Yields the job.
    #
    # &block - Proc or Lambda to be run when the event is triggered.
    #
    # Examples
    #
    #   job.on_complete do |job|
    #     puts "Job ##{job.id} completed!"
    #   end
    #
    #   job.on_error do |job|
    #     puts "Job failed!"
    #   end
    #
    #   job.on_poll do |job|
    #     puts "Polled status for #{job.id}"
    #   end
    #
    # Returns self.
    #
    # Signature
    #
    #   on_complete(&block)
    #   on_error(&block)
    #   on_poll(&block)
    %w[complete error poll].each do |type|
      define_method :"on_#{type}" do |&block|
        @_callbacks[:"on_#{type}"] << block
        self
      end
    end

    # Public: Queries the job status from the API.
    #
    # Examples
    #
    #   job.status
    #   # => { :id => '1234', :done => false, ... }
    #
    # Returns the AsyncResult (http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_asyncresult.htm).
    def status
      @status ||= client.status(id)
    end

    # Public: Returns true if the job has completed. 
    #
    # Examples
    #
    #   job.done
    #   # => true
    #
    # Returns true if the job has completed, false otherwise.
    def done?
      status.done
    end

    # Public: Returns the state if the job has finished processing.
    #
    # Examples
    #
    #   job.state
    #   # => 'Completed'
    #
    # Returns the state of the job.
    def state
      status.state
    end

    # Public: Check if the job is in a given state.
    #
    # Examples
    #
    #   job.queued?
    #   # => false
    #
    # Returns true or false.
    #
    # Signature
    #
    #   queued?
    #   in_progress?
    #   completed?
    #   error?
    %w[Queued InProgress Completed Error].each do |state|
      define_method :"#{state.underscore}?" do; self.state == state end
    end

    def inspect
      "#<#{self.class} @id=#{@id.inspect}>"
    end

    class << self

      # Internal: Disable threading in tests.
      def disable_threading!
        self.class_eval do
          def start_heart_beat
            delay = DELAY_START
            loop do
              @status = nil
              wait (delay = delay * DELAY_MULTIPLIER)
              trigger_poll_callbacks
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
        delay = DELAY_START
        loop do
          @status = nil
          wait (delay = delay * DELAY_MULTIPLIER)
          trigger_poll_callbacks
          trigger_callbacks && Thread.stop if completed? || error?
        end
      end
    end

    def trigger_poll_callbacks
      @_callbacks[:on_poll].each do |block|
        block.call(self)
      end
    end

    def wait(duration)
      sleep duration
    end

    def trigger_callbacks
      @_callbacks[callback_type].each do |block|
        block.call(self)
      end
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
