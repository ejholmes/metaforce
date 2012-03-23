require "spec_helper"

describe String do

  describe ".lower_camelcase" do
    it "camelCases underscored_words" do
      "hello_world".lower_camelcase.should eq("helloWorld")
    end
  end

  describe ".camelcase" do
    it "CamelCases underscored_words" do
      "hello_world".camelcase.should eq("HelloWorld")
    end
  end

  describe ".underscore" do
    it "underscores CamelCased words" do
      "HelloWorld".underscore.should eq("hello_world")
    end
  end

end
