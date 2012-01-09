require "metaforce/git"

describe Metaforce::Git do
  before(:all) do
    @package_xml = File.open(File.join(File.dirname(__FILE__), 'fixtures/package.xml'), 'r').read
  end
  before(:each) do
    @git_output = <<-OUTPUT
D       src/classes/TestClass.cls
M       src/components/Component.component
A       src/staticResources/Assets.staticresource
OUTPUT
  end
  context "git diff" do
    it "generates a package and destructive changes" do
      changes = Metaforce::Git.new(@package_xml)
      changes.diff(@git_output)
      @package = {
        :apex_component => ['Component'],
        :static_resource => ['Assets']
      }
      @destructive = {
        :apex_class => ['TestClass']
      }
      changes.package.to_hash.should eq(@package)
      changes.destructive.to_hash.should eq(@destructive)
    end
    it "does something" do
      Dir.chdir File.join(File.dirname(__FILE__), 'fixtures/sample')
      changes = Metaforce::Git.diff('HEAD~1', 'HEAD', File.open(File.join(File.dirname(__FILE__), 'fixtures/package.xml'), 'r').read)
      @package = {
        :static_resource => ['Assets']
      }
      changes.package.to_hash.should eq(@package);
    end
  end
end
