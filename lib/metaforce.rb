require 'savon'

require 'metaforce/version'
require 'metaforce/login'
require 'metaforce/client'
require 'metaforce/services'
require 'metaforce/metadata'

module Metaforce
  class << self
    # Performs a login and retrurns the session
    def login(username, password, security_token=nil)
      Login.new(username, password, security_token).login
    end
  end
end
