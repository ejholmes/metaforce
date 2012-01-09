require "metaforce/package"
require "nokogiri"

describe Metaforce::Package do
  before(:all) do
    @package_xml = File.open(File.join(File.dirname(__FILE__), 'fixtures/package.xml'), 'r').read
    @package_hash = {
      :apex_class => ['TestClass', 'AnotherClass'],
      :apex_component => ['Component'],
      :static_resource => ['Assets']
    }
  end
  context "when given a hash" do
    it "returns a string containing xml" do
      package = Metaforce::Package.new(@package_hash)
      response = package.to_xml
      response.should eq(@package_xml)
    end
  end
  context "parse" do
    it "returns a hash" do
      package = Metaforce::Package.new(@package_xml)
      response = package.to_hash
      response.should eq(@package_hash)
    end
  end
end
