require 'bundler'
Bundler.require :default
require 'pp'

RSpec.configure do |config|
  config.include Savon::Spec::Macros
end

Savon.configure do |config|
  config.log = false
end

Savon::Spec::Fixture.path = File.join(File.dirname(__FILE__), 'fixtures/requests')
