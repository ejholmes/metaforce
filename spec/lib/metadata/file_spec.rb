require "spec_helper"

describe Metaforce::Metadata::MetadataFile do
  describe "#template" do
    it "returns a hash" do
      file = Metaforce::Metadata::MetadataFile.template(:apex_page)
      file.should be_a(Hash)
    end
  end

  describe ".to_xml" do
    it "returns a string representation of the hash" do
      file = Metaforce::Metadata::MetadataFile.template(:apex_page)
      file.to_xml.should be_a(String)
    end
  end
end
