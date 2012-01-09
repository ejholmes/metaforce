require "metaforce/package"
require "nokogiri"

describe Metaforce::Package do
  before(:all) do
    @package_xml = File.open(File.join(File.dirname(__FILE__), 'fixtures/package.xml'), 'r').read
  end
  before(:each) do
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
    context "add components" do
      it "can add additional components" do
        package = Metaforce::Package.new(@package_hash)
        package.add(:apex_class, 'AdditionalClass')
        response = package.to_hash
        @package_hash = {
          :apex_class => ['TestClass', 'AnotherClass', 'AdditionalClass'],
          :apex_component => ['Component'],
          :static_resource => ['Assets']
        }
        response.should eq(@package_hash)
      end
      it "can add additional components from an array" do
        package = Metaforce::Package.new(@package_hash)
        package.add(:apex_class, ['class1', 'class2'])
        response = package.to_hash
        @package_hash = {
          :apex_class => ['TestClass', 'AnotherClass', 'class1', 'class2'],
          :apex_component => ['Component'],
          :static_resource => ['Assets']
        }
        response.should eq(@package_hash)
      end
      it "strips directories and extensions" do
        package = Metaforce::Package.new(@package_hash)
        package.add(:apex_class, 'src/classes/AdditionalClass.cls')
        response = package.to_hash
        @package_hash = {
          :apex_class => ['TestClass', 'AnotherClass', 'AdditionalClass'],
          :apex_component => ['Component'],
          :static_resource => ['Assets']
        }
        response.should eq(@package_hash)
      end
    end
    context "remove components" do
      it "can remove components" do
        package = Metaforce::Package.new(@package_hash)
        package.remove(:apex_class, 'TestClass')
        response = package.to_hash
        @package_hash = {
          :apex_class => ['AnotherClass'],
          :apex_component => ['Component'],
          :static_resource => ['Assets']
        }
        response.should eq(@package_hash)
      end
      it "can remove components in an array" do
        package = Metaforce::Package.new(@package_hash)
        package.remove(:apex_class, ['TestClass', 'AnotherClass'])
        response = package.to_hash
        @package_hash = {
          :apex_component => ['Component'],
          :static_resource => ['Assets']
        }
        response.should eq(@package_hash)
      end
      it "strips directories and extensions" do
        package = Metaforce::Package.new(@package_hash)
        package.remove(:apex_class, 'src/classes/TestClass.cls')
        response = package.to_hash
        @package_hash = {
          :apex_class => ['AnotherClass'],
          :apex_component => ['Component'],
          :static_resource => ['Assets']
        }
        response.should eq(@package_hash)
      end
    end
    context "filter components" do
      it "filters the components based on a list of files" do
        package = Metaforce::Package.new(@package_hash)
        package.only(['classes/TestClass'])
        response = package.to_hash
        @package_hash = {
          :apex_class => ['TestClass']
        }
        response.should eq(@package_hash)
      end
      it "ignores file extensions" do
        package = Metaforce::Package.new(@package_hash)
        package.only(['classes/TestClass.cls', 'components/Component.component'])
        response = package.to_hash
        @package_hash = {
          :apex_class => ['TestClass'],
          :apex_component => ['Component']
        }
        response.should eq(@package_hash)
      end
      it "strips any leading directories" do
        package = Metaforce::Package.new(@package_hash)
        package.only(['src/classes/TestClass.cls', 'src/components/Component.component'])
        response = package.to_hash
        @package_hash = {
          :apex_class => ['TestClass'],
          :apex_component => ['Component']
        }
        response.should eq(@package_hash)
      end
      it "ignores case of folder" do
        package = Metaforce::Package.new(@package_hash)
        package.only(['src/Classes/TestClass.cls', 'src/Components/Component.component'])
        response = package.to_hash
        @package_hash = {
          :apex_class => ['TestClass'],
          :apex_component => ['Component']
        }
        response.should eq(@package_hash)
      end
    end
  end
  context "when given a string" do
    it "parses the xml content" do
      package = Metaforce::Package.new(@package_xml)
      response = package.to_hash
      response.should eq(@package_hash)
    end
  end
end
