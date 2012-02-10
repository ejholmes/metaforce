namespace :metaforce do
  Metaforce.log = true

  task :require do
    require 'metaforce'
  end

  task :login do
    print "username: "; username = STDIN.gets.chomp
    print "password: "; password = STDIN.gets.chomp
    print "security token: "; security_token = STDIN.gets.chomp
    @client = Metaforce::Metadata::Client.new :username => username,
      :password => password,
      :security_token => security_token
  end

  desc "Deploy current directory to the organization"
  task :deploy => :login do
    deployment = @client.deploy File.dirname(__FILE__)
    result = deployment.result(:wait_until_done => true)
    if result[:success]
      puts "Successfully deployed metadata."
    else
      puts "An error occurred."
    end
  end

  desc "Retrieve metadata from the organization to src directory"
  task :retrieve => :login do
    retrieval = @client.retrieve_unpackaged(File.expand_path('src/package.xml'))
    result = retrieval.result(:wait_until_done => true)
    retrieval.unzip(File.expand_path('src'))
    puts "Successfully retrieved metadata."
  end

end
