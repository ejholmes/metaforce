class LoginDetails 
	require 'yaml'

	attr_accessor :username, :password, :security_token, :sandbox, :log
	STORAGE_LOCATION = "#{Dir.pwd}/.git/force.com.config"

	def initialize(user, pass, security_token, sandbox, log = nil)
		@username 		= user
		@password 		= pass
		@security_token = security_token
		@sandbox 		= sandbox
		@log 			= log
	end

	def save!
		File.open(STORAGE_LOCATION, "w+") do |file|
			file.print Marshal::dump(self)
		end
	end

	def self.load
		$/="---_---" #record separator
		File.open(STORAGE_LOCATION, "r") do |object|
			return Marshal::load(object)
		end
	end

end