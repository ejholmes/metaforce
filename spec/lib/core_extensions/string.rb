require "spec_helper"

describe String do

  it "camelCases underscored_words" do
    "hello_world".camelCase.should eq("helloWorld")
  end

end
