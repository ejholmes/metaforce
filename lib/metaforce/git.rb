require 'metaforce/package'

module Metaforce
  class Git
    attr_reader :package
    attr_reader :destructive

    def initialize(base)
      @package = Package.new(base)
      @destructive = Package.new(base)
    end

    # Takes a string and generates a package.xml and destructiveChanges.xml
    # file
    def diff(git_output)
      lines = git_output.split("\n")
      destructive = []
      package = []

      lines.each do |line|
        parts = line.split(" ")
        if parts[0] == "A" || parts[0] == "M"
          package.push(parts[1])
        elsif parts[0] == "D"
          destructive.push(parts[1])
        end
      end

      @package.only(package)
      @destructive.only(destructive)
    end
  end
end
