require "bundler"
Bundler.require :default, :development
require "pp"

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Savon::Spec::Macros
end

Savon.configure do |config|
  config.log = false
end
Savon::Spec::Fixture.path = File.join(File.dirname(__FILE__), 'fixtures/requests')
