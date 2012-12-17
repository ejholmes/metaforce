module Metaforce
  class Client
    module Services
      
      # Public: Used to interact with the Services API.
      def services
        @services ||= Metaforce::Services::Client.new(@options)
      end

    end
  end
end
