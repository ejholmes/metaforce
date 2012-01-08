require "metaforce/package"
require "nokogiri"

test_hash = {
  :apex_class => ['TestClass'],
  :apex_component => ['Component']
}

describe Metaforce::Package do
  package_xml = File.open(File.join(File.dirname(__FILE__), 'fixtures/package.xml'), 'r').read

  context "When given a hash" do
    it "returns a string containing xml" do
      package = Metaforce::Package.new(test_hash)
      response = package.to_xml
      response.should eq(package_xml)
    end
  end
  context "Parse" do
    it "returns a hash" do
      package = Metaforce::Package.new
      response = package.parse(package_xml).to_hash
      response.should eq(test_hash)
    end
  end
end
