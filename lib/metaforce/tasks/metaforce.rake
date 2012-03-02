namespace :metaforce do
  Metaforce.log = true

  task :login do
    if File.exists?('metaforce.yml')
      require 'yaml'
      config = YAML.load_file('metaforce.yml')
      env = ENV['env'] || 'default'
      root = config.has_key?(env) ? config[env] : config
      username       = root["username"]
      password       = root["password"]
      security_token = root["security_token"] || ''
      test           = root["test"] || false
      Metaforce.configuration.test = test
    else
      print "username: "; username = STDIN.gets.chomp
      print "password: "; password = STDIN.gets.chomp
      print "security token: "; security_token = STDIN.gets.chomp
    end
    @client = Metaforce::Metadata::Client.new :username => username,
      :password => password,
      :security_token => security_token
  end

  desc "Deploy current directory to the organization"
  task :deploy => :login do
    dir = ENV['dir'] || 'src'
    deployment = @client.deploy File.join(File.dirname(__FILE__), dir)
    result = deployment.result(:wait_until_done => true)
    if result[:success]
      puts "Successfully deployed metadata."
    else
      puts "An error occurred."
    end
  end

  desc "Retrieve metadata from the organization to src directory"
  task :retrieve => :login do
    dir = ENV['dir'] || 'src'
    retrieval = @client.retrieve_unpackaged(File.expand_path('src/package.xml'))
    result = retrieval.result(:wait_until_done => true)
    retrieval.to(File.expand_path(dir))
    puts "Successfully retrieved metadata to '#{dir}'."
  end

end
