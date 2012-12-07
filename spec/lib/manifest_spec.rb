require "spec_helper"

describe Metaforce::Manifest do
  let(:package_xml) { File.open(File.join(File.dirname(__FILE__), '../fixtures/package.xml'), 'r').read }
  let(:package_hash) do
    { :apex_class => ['TestClass', 'AnotherClass'],
      :apex_component => ['Component'],
      :static_resource => ['Assets'] }
  end
  let(:package) { package_xml }
  let(:manifest) { described_class.new(package) }

  describe '.to_xml' do
    let(:package) { package_hash }
    subject { manifest.to_xml }
    it { should eq package_xml }
  end

  describe '.to_hash' do
    let(:package) { package_xml }
    subject { manifest.to_hash }
    it { should eq package_hash }
  end

  describe '.to_package' do
    subject { manifest.to_package }
    it do
      should eq [
        { :members => ['TestClass', 'AnotherClass'], :name => 'ApexClass' },
        { :members => ['Component'], :name => 'ApexComponent' },
        { :members => ['Assets'], :name => 'StaticResource' }
      ]
    end
  end
end
