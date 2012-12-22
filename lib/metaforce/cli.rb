require 'listen'
require 'thor'
require 'metaforce/reporters'
require 'metaforce/reporters'

Metaforce.configuration.log = false
Metaforce::Job.disable_threading!

module Metaforce
  class CLI < Thor
    CONFIG_FILE = '.metaforce.yml'

    include Thor::Actions

    class << self
      def credential_options
        method_option :username, :aliases => '-u', :desc => 'Username.'
        method_option :password, :aliases => '-p', :desc => 'Password.'
        method_option :security_token, :aliases => '-t', :desc => 'Security Token.'
        method_option :environment, :aliases => '-e', :default => 'production', :desc => 'Environment to use from config file (if present).'
        method_option :host, :aliases => '-h', :desc => 'Salesforce host to connect to.'
      end

      def deploy_options
        method_option :deploy_options, :aliases => '-o', :type => :hash, :default => { :run_all_tests => true }, :desc => 'Deploy Options'
      end

      def retrieve_options
        method_option :retrieve_options, :aliases => '-o', :type => :hash, :default => {}, :desc => 'Retrieve Options'
      end
    end

    desc 'deploy <path>', 'Deploy <path> to the target organization.'

    credential_options
    deploy_options

    def deploy(path)
      say "Deploying: #{path} ", :cyan
      say "#{options[:deploy_options].inspect}"
      client(options).deploy(path, options[:deploy_options].symbolize_keys!)
        .on_complete { |job| Metaforce::Reporters::DeployReporter.new(job.result).report }
        .on_error(&error)
        .on_poll(&polling)
        .perform
    end

    desc 'retrieve <manifest> <path>', 'Retrieve the components specified in <manifest> (package.xml) to <path>.'

    credential_options
    retrieve_options

    def retrieve(manifest, path)
      say "Retrieving: #{manifest} ", :cyan
      say "#{options[:retrieve_options].inspect}"
      client(options).retrieve_unpackaged(manifest, options[:retrieve_options].symbolize_keys!)
        .extract_to(path)
        .on_complete { |job| Metaforce::Reporters::RetrieveReporter.new(job.result).report }
        .on_complete { |job| say "Extracted: #{path}", :green }
        .on_error(&error)
        .on_poll(&polling)
        .perform
    end

    desc 'watch <path>', 'Deploy <path> to the target organization whenever files are changed.'

    credential_options
    deploy_options

    def watch(path)
      say "Watching: #{path}"
      Listen.to(path) { deploy path }
    end

  private

    def error
      proc { |job| say "Error: #{job.result.inspect}" }
    end

    def polling
      proc { |job| say 'Polling ...', :cyan }
    end

    def client(options)
      credentials = Thor::CoreExt::HashWithIndifferentAccess.new(config ? config[options[:environment]] : {})
      credentials.merge!(options.slice(:username, :password, :security_token, :host))
      credentials.tap do |credentials|
        credentials[:username] ||= ask('username:')
        credentials[:password] ||= ask('password:')
        credentials[:security_token] ||= ask('security token:')
      end
      Metaforce.new credentials
    end

    def config
      YAML.load(File.open(config_file)) if File.exists?(config_file)
    end

    def config_file
      File.expand_path(CONFIG_FILE)
    end

  end
end
