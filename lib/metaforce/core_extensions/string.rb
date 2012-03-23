module Metaforce
  module CoreExtensions
    module String

      def lower_camelcase
        str = dup
        str.gsub!(/_[a-z]/) { |a| a.upcase }
        str.gsub!('_', '')
        str
      end unless method_defined?(:lower_camelcase)

      def underscore
        self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr("-", "_").
        downcase
      end unless method_defined?(:underscore)
    
    end
  end
end

String.send :include, Metaforce::CoreExtensions::String
