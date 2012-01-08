require "metaforce/package"
require "nokogiri"

describe Metaforce::Package do
  context "When given a hash" do
    it "returns a string containing xml" do
      package = Metaforce::Package.new({
        :apex_class => ['TestClass']
      })
      response = package.to_xml
      xml = <<-XML
<?xml version="1.0"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
  <types>
    <members>TestClass</members>
    <name>ApexClass</name>
  </types>
  <version>23.0</version>
</Package>
XML
      response.should eq(xml)
    end
  end
end
