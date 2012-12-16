require 'spec_helper'

describe Metaforce do
  describe '.configuration' do
    subject { Metaforce.configuration }
    it { should set_default(:api_version).to('26.0') }
    it { should set_default(:host).to('login.salesforce.com') }
    it { should set_default(:endpoint).to('https://login.salesforce.com/services/Soap/u/26.0') }
    it { should set_default(:partner_wsdl).to(File.expand_path('../../../wsdl/26.0/partner.xml', __FILE__)) }
    it { should set_default(:metadata_wsdl).to(File.expand_path('../../../wsdl/26.0/metadata.xml', __FILE__)) }
  end
end
