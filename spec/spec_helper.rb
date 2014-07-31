require 'bundler'
Bundler.require :default, :development
require 'pp'
require 'rspec/mocks'
require 'rspec/its'

Dir['./spec/support/**/*.rb'].sort.each {|f| require f}

RSpec.configure do |config|
  config.mock_with :rspec
  config.include Savon::Spec::Macros

  config.before(:each) do
    Metaforce.configuration.threading = false
    allow_any_instance_of(Metaforce::Job).to(receive(:sleep))
  end
end

RSpec::Matchers.define :set_default do |option|
  chain :to do |value|
    @value = value
  end

  match do |configuration|
    @actual = configuration.send(option.to_sym)
    expect(@actual).to eq @value
  end

  failure_message do |configuration|
    "Expected #{option} to be set to #{@value.inspect}, got #{@actual.inspect}"
  end
end

Savon.configure do |config|
  config.log = false
end

Savon::Spec::Fixture.path = File.join(File.dirname(__FILE__), 'fixtures/requests')
