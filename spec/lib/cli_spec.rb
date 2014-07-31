require 'spec_helper'
require 'metaforce/cli'

describe Metaforce::CLI do
  before do
    allow_any_instance_of(Metaforce::Client).to receive(:deploy).and_return(double('deploy job').as_null_object)
    allow_any_instance_of(Metaforce::Client).to receive(:retrieve).and_return(double('retrieve job').as_null_object)
    allow(subject).to receive(:config).and_return(nil)
  end

  describe 'credentials' do
    let(:output) { capture(:stdout) { subject.deploy('./path') } }

    context 'when supplied credentials from the command line' do
      let(:options) { indifferent_hash(:username => 'foo', :password => 'bar', :security_token => 'token', :deploy_options => {}) }

      it 'uses supplied credentials from command line' do
        subject.options = options
        expect(Metaforce).to receive(:new).with(indifferent_hash(options).slice(:username, :password, :security_token)).and_call_original
        expect(output).to include('Deploying: ./path')
      end
    end

    context 'when supplied credentials from config file' do
      let(:options) { indifferent_hash(:environment => 'production', :deploy_options => {}) }
      let(:config) { { 'username' => 'foo', 'password' => 'bar', 'security_token' => 'token' } }

      it 'uses credentials from the config file' do
        subject.options = options
        allow(subject).to receive(:config).and_return('production' => config)
        expect(Metaforce).to receive(:new).with(indifferent_hash(config)).and_call_original
        expect(output).to include('Deploying: ./path')
      end
    end
  end

  def indifferent_hash(hash)
    Thor::CoreExt::HashWithIndifferentAccess.new(hash)
  end
end
