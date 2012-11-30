module Metaforce
  class Job::Retrieve < Job
    def initialize(client, options={})
      super(client)
      @options = options
    end
  end
end
