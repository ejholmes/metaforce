require 'thor' #should probably be in say, lib/metaforce.rb, but I don't want to make that decision alone.

class MetaForce < Thor
	include Thor::Actions
	require './lib/metaforce/custom_actions'
	require './lib/metaforce/login_details'
	require './lib/metaforce'
	include Thor::Actions::CustomActions

	######## Tasks ############################################################
	desc "login", "accepts login parameters and completes a soap call to salesforce via the partner api."
	method_option :reset, :type => :boolean, :aliases => "-r", :required => false, :banner => " Reset stored login information"
	def login
		if ((File.exists? LoginDetails::STORAGE_LOCATION) && (options[:reset].nil?))
			say "Using stored login information"
			@login_details = LoginDetails.load
		else
			login_email 			= ask "Login Email address: "
			sandbox					= yes? "Is this a sandbox org login: "
			login_pass  			= masked_ask "Login Password: "
			login_security_token	= masked_ask "Security Token: "
			say "If you'd like I can save this login information to this directories .git/config/force.com.config"
			say "----- PLEASE NOTE, HOWEVER, THAT SAVING THIS INFORMATION IS INSECURE AND IS IN NO WAY ENCRYPTED"
			save 					= yes? "Should I save this Login information? (y/n) "

			if save
				@login_details = LoginDetails.new(login_email, login_pass, login_security_token, sandbox)
				@login_details.save!
			else
				@login_details = LoginDetails.new(login_email, login_pass, login_security_token, sandbox)
			end
		end

		raise "Failed to find viable login information!" if @login_details.nil?
		Metaforce.log = @login_details.log
		Metaforce.configuration.test = @login_details.sandbox
		@client = Metaforce::Metadata::Client.new :username => @login_details.username,
		:password => @login_details.password,
		:security_token => @login_details.security_token
	end	
	
	######## Deploy ###########################################################
	desc "deploy", "deploys the current working directory's src folder to salesforce"
	method_option :dir, :type => :string, :aliases => "-d", :required => true, :default => "src", :banner => "Specify the directory to deploy"
	method_option :reset, :type => :boolean, :aliases => "-r", :required => false, :banner => " Reset stored login information"
	def deploy
		login unless @client
		login unless options[:reset].nil?
		raise "failed to create connection!" unless @client
		deploy_results = @client.deploy(options[:dir]).result
		say "Deploy Successful!", color = Thor::Shell::Color::GREEN if deploy_results[:success]
	end

	######## RunTests #########################################################
	desc "test", "runs _all_ salesforce unit tests!"
	method_option :dir, :type => :string, :aliases => "-d", :required => true, :default => "src", :banner => "Specify the directory to execute tests"
	method_option :reset, :type => :boolean, :aliases => "-r", :required => false, :banner => " Reset stored login information"
	def test
		login unless @client
		login unless options[:reset].nil?
		raise "failed to create connection!" unless @client
		result = spinner {
			result = @client.deploy(options[:dir], :options => { :run_all_tests => true }).result
		}
		failures = result[:run_test_result][:failures]
		if failures
			failures = [failures] unless failures.responds_to? :each
			say "--- FAILURES: ", color = Thor::Shell::Color::RED
			failures.each_with_index do |f,i|
				say "#{"-" * 80}", color = Thor::Shell::Color::YELLOW
				say ""
				say "\t(#{index +1}) #{failure[:method_name]}"
				say "\t\t#{failure[:message]}", color = Thor::Shell::Color::RED
				say ""
				say "\t\t#{failure[:stack_trace]}", color => Thor::Shell::Color::MAGENTA
				say ""
			end
		end

		color = (failures) ? Thor::Shell::Color::RED : Thor::Shell::Color::GREEN
		say "Finished in #{Float(result[:run_test_result][:total_time]) / 100} seconds"
		say "#{result[:run_test_result][:num_tests_run]} tests, #{result[:run_test_result][:num_failures]} failures", color = color
	end

	######## Pull #############################################################
	desc "pull", "Pull all MetaData objects specified in the package.xml file"
	method_option :reset, :type => :boolean, :aliases => "-r", :required => false, :banner => " Reset stored login information"
	method_option :manifest, :type => :string, :aliases => "-m", :required => true, :banner => " Path to Manifest.xml", :default => "src/package.xml"
	method_option :dir, :type => :string, :aliases => "-d", :required => false, :banner => " Download to directory", :default => "retrieved"
	def pull
		login unless @client
		login unless options[:reset].nil?
		raise "failed to create connection!" unless @client
		result = spinner {
			@client.retrieve_unpackaged(options[:manifest]).to(options[:dir])
		}
        say "Files retrieved sucessfully to #{@directory}", color = Thor::Shell::Color::GREEN
	end

	######## Clone ############################################################
	desc "clone", "Pull all MetaData objects from the current org"
	method_option :reset, :type => :boolean, :aliases => "-r", :required => false, :banner => " Reset stored login information"
	method_option :manifest, :type => :string, :aliases => "-m", :required => true, :banner => " Path to Manifest.xml", :default => "src/package.xml"
	method_option :dir, :type => :string, :aliases => "-d", :required => false, :banner => " Download to directory", :default => "retrieved"
	def clone
		login unless @client
		login unless options[:reset].nil?
		raise "failed to create connection!" unless @client
		result = spinner {
			@client.retrieve
		}
		puts result.inspect
        say "Files retrieved sucessfully to #{options[:dir]}", color = Thor::Shell::Color::GREEN
	end

end