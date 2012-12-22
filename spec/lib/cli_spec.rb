require 'spec_helper'
require 'metaforce/cli'

describe Metaforce::CLI do
  before do
    Metaforce::Client.any_instance.stub(:deploy).and_return(double('deploy job').as_null_object)
    Metaforce::Client.any_instance.stub(:retrieve).and_return(double('retrieve job').as_null_object)
    subject.stub(:config).and_return(nil)
  end

  describe 'credentials' do
    let(:output) { capture(:stdout) { subject.deploy('./path') } }

    context 'when supplied credentials from the command line' do
      let(:options) { indifferent_hash(:username => 'foo', :password => 'bar', :security_token => 'token', :deploy_options => {}) }

      it 'uses supplied credentials from command line' do
        subject.options = options
        Metaforce.should_receive(:new).with(indifferent_hash(options).slice(:username, :password, :security_token)).and_call_original
        output.should include('Deploying: ./path')
      end
    end

    context 'when supplied credentials from config file' do
      let(:options) { indifferent_hash(:environment => 'production', :deploy_options => {}) }
      let(:config) { { 'username' => 'foo', 'password' => 'bar', 'security_token' => 'token' } }

      it 'uses credentials from the config file' do
        subject.options = options
        subject.stub(:config).and_return('production' => config)
        Metaforce.should_receive(:new).with(indifferent_hash(config)).and_call_original
        output.should include('Deploying: ./path')
      end
    end
  end

  def indifferent_hash(hash)
    Thor::CoreExt::HashWithIndifferentAccess.new(hash)
  end
end
