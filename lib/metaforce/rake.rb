require 'yaml'
require 'metaforce/rake/deploy'
require 'metaforce/rake/retrieve'
require 'metaforce/rake/tests'

module Metaforce
  module Rake

    class << self
      CONFIG_FILE = 'metaforce.yml'

      # Loads the config and creates a client
      def client
        load_config
        Metaforce::Metadata::Client.new :username => @username,
          :password => @password,
          :security_token => @security_token
      end

      # Loads configuration settings from metaforce.yml
      def load_config
        if File.exists?(CONFIG_FILE)
          config = YAML.load_file(CONFIG_FILE)
          env = ENV['env'] || 'default'
          config = config.has_key?(env) ? config[env] : config
          @username       = config["username"]
          @password       = config["password"]
          @security_token = config["security_token"] || ''
          @test           = config["test"] || false
          @log            = config["log"] || true
          Metaforce.log = @log
          Metaforce.configuration.test = @test
        else
          print "username: "; @username = STDIN.gets.chomp
          print "password: "; @password = STDIN.gets.chomp
          print "security token: "; @security_token = STDIN.gets.chomp
          Metaforce.log = true
        end
      end

    end
  end
end
