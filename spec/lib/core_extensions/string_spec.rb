require "spec_helper"

describe String do

  describe ".camelCase" do

    it "camelCases underscored_words" do
      "hello_world".camelCase.should eq("helloWorld")
    end

  end

  describe ".underscore" do

    it "underscores CamelCased words" do
      "HelloWorld".underscore.should eq("hello_world")
    end

  end

end
