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

    # Public: Register a block to be called when the job has completed.
    #
    # Yields the job.
    #
    # &block - Proc or Lambda to be run when the job completes.
    #
    # Examples
    #
    #   job.on_complete do |job|
    #     puts "Job ##{job.id} completed!"
    #   end
    #
    # Returns self.
    def on_complete(&block)
      @_callbacks[:on_complete] << block
      self
    end

    # Public: Register a block to be called when if the job fails.
    #
    # Yields the job.
    #
    # &block - Proc or Lambda to be run when the job fails.
    #
    # Examples
    #
    #   job.on_error do |job|
    #     puts "Job ##{job.id} failed!"
    #   end
    #
    # Returns self.
    def on_error(&block)
      @_callbacks[:on_error] << block
      self
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
      client.status(id)
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
    # Returns the state if the job is done, false otherwise.
    def state
      done? && status.state
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
