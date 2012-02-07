module Metaforce
  module CoreExtensions
    module String

      def camelCase
        str = dup
        str.gsub!(/_[a-z]/) { |a| a.upcase }
        str.gsub!('_', '')
        str
      end unless method_defined?(:camelCase)
    
    end
  end
end

String.send :include, Metaforce::CoreExtensions::String
