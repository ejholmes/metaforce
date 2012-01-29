module Metaforce
  module DSL
    module Metadata
      def login(options)
        @client = Metaforce::Metadata::Client.new options
      end

      def deploy(dir)
        deployment = @client.deploy dir
        result = deployment.result :wait_until_done => true
        raise "Deployment failed" if !result[:success]
        yield result if block_given?
      end
      
      def retrieve
      end
    end
  end
end
