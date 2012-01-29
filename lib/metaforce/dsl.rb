module Metaforce
  module DSL
    module Metadata
      def login(options)
        @client = Metaforce::Metadata::Client.new options
      end

      def deploy(dir, options={})
        deployment = @client.deploy dir, options
        result = deployment.result :wait_until_done => true
        raise "Deploy failed." if !result[:success]
        yield result if block_given?
      end
      
      def retrieve(manifest)
        retrieval = @client.retrieve_unpackaged manifest
        result = retrieval.result :wait_until_done => true
        yield result if block_given?
      end
    end
  end
end
