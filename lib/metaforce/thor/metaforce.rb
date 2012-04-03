class MetaForce < Thor
	include Thor::Actions
	include Utility

	desc "login", "accepts login parameters and completes a soap call to salesforce via the partner api."
	def login
		if File.exists? LoginDetails::STORAGE_LOCATION
			say "using stored login information"
			@login_details = LoginDetails.load
			@connection = PartnerApi.login(@login_details.username, @login_details.password, @login_details.security_token)
		else
			login_email 			= ask "Login Email address: "
			login_pass  			= masked_ask "Login Password     : "
			login_security_token	= masked_ask "Security Token     : "
			say "If you'd like I can save this login information to this directories .git/config/force.com.config"
			say "----- PLEASE NOTE, HOWEVER, THAT SAVING THIS INFORMATION IS INSECURE AND IS IN NO WAY ENCRYPTED"
			save = yes? 	  "Should I save this Login information? (y/n) "

			if save
				LoginDetails.new(login_email, login_pass, login_security_token).save
			else
				@login_details = LoginDetails.new(login_email, login_pass, login_security_token)
				@connection = PartnerApi.login(@login_details.username, @login_details.password, @login_details.security_token)
			end

		end
	end	

end