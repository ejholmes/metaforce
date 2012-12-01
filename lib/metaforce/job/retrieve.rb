module Metaforce
  class Job::Retrieve < Job
    def initialize(client, options={})
      super(client)
      @options = options
    end

    def perform
      super
    end
  end
end
