Metaforce
=========
Metaforce is a Ruby gem for interecting with the [Salesforce Metadata API](http://www.salesforce.com/us/developer/docs/api_meta/index.htm).
The goal of this project is to make the Migration Tool obsolete.

Usage
-----

``` ruby
client = Metaforce::Metadata::Client.new('username', 'password', 'security token')

client.deploy do |package|
  package.root 
end

client.retrieve do |package|
  
end
```
