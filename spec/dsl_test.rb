require "metaforce"
require "metaforce/dsl"
include Metaforce::DSL::Metadata

Savon.log = false

login :username => ENV["SFDC_USERNAME"], :password => ENV["SFDC_PASSWORD"], :security_token => ENV["SFDC_SECURITY_TOKEN"]

deploy File.expand_path("../fixtures/sample", __FILE__) do |result|
  puts result
end

manifest = Metaforce::Manifest.new File.open(File.expand_path("../fixtures/sample/src/package.xml", __FILE__)).read
retrieve manifest do |result, zip|
  puts zip
end
