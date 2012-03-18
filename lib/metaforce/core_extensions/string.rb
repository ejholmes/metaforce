module Metaforce
  module CoreExtensions
    module String

      def camelCase
        str = dup
        str.gsub!(/_[a-z]/) { |a| a.upcase }
        str.gsub!('_', '')
        str
      end unless method_defined?(:camelCase)

      def underscore
        self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
      end
    
    end
  end
end

String.send :include, Metaforce::CoreExtensions::String
