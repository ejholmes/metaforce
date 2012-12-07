require 'bundler'
Bundler.require :default, :development
require 'pp'

Dir['./spec/support/**/*.rb'].sort.each {|f| require f}

RSpec.configure do |config|
  config.include Savon::Spec::Macros

  config.before do
    # Stub out the heart beat so we don't get weird test failures.
    Metaforce::Job.any_instance.stub(:start_heart_beat)
  end
end

RSpec::Matchers.define :set_default do |option|
  chain :to do |value|
    @value = value
  end

  match do |configuration|
    @actual = configuration.send(option.to_sym)
    @actual.should eq @value
  end

  failure_message_for_should do |configuration|
    "Expected #{option} to be set to #{@value.inspect}, got #{@actual.inspect}"
  end
end

Savon.configure do |config|
  config.log = false
end

Savon::Spec::Fixture.path = File.join(File.dirname(__FILE__), 'fixtures/requests')
