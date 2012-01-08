require "metaforce/package"
require "nokogiri"

test_xml = <<-XML
<?xml version="1.0"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
  <types>
    <members>TestClass</members>
    <name>ApexClass</name>
  </types>
  <version>23.0</version>
</Package>
XML

describe Metaforce::Package do
  context "When given a hash" do
    it "returns a string containing xml" do
      package = Metaforce::Package.new({
        :apex_class => ['TestClass']
      })
      response = package.to_xml
      response.should eq(test_xml)
    end
  end
  context "Parse" do
    it "returns a hash" do
      package = Metaforce::Package.new
      response = package.parse(test_xml)
      response.should eq({
        :apex_class => ['TestClass']
      })
    end
  end
end
