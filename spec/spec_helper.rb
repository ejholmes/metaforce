require "bundler"
Bundler.require :default, :development

RSpec.configure do |config|
  config.mock_with :mocha
  config.include Savon::Spec::Macros
end

Savon.log = false
Savon::Spec::Fixture.path = File.expand_path('fixtures/requests', __FILE__)
