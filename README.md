# Metaforce
![travis-ci](https://secure.travis-ci.org/ejholmes/metaforce.png)

Metaforce is a Ruby gem for interacting with the [Salesforce Metadata API](http://www.salesforce.com/us/developer/docs/api_meta/index.htm).
The goal of this project is to make the [Migration Tool](http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_deploying_ant.htm) obsolete, favoring Rake over Ant.

**Metaforce is in active development and is currently in alpha status. Don't use
it to deploy code to production instances. You've been warned!**

## Installation
```bash
gem install metaforce --pre
```

## Usage
``` ruby
client = Metaforce::Metadata::Client.new :username => 'username',
    :password => 'password',
    :security_token => 'security token')

client.describe
# => { :metadata_objects => [{ :child_xml_names => "CustomLabel", :directory_name => "labels" ... }

client.list(:type => "CustomObject")
# => [{ :created_by_id => "005U0000000EGpcIAG", :created_by_name => "Eric Holmes", ... }]

deployment = client.deploy(File.dirname(__FILE__))
# => #<Metaforce::Transaction:0x00000102779bf8 @id="04sU0000000WNWoIAO" @type=:deploy> 

deployment.done?
# => false

deployment.result(:wait_until_done => true)
# => { :id => "04sU0000000WNWoIAO", :messages => [{ :changed => true ... :success => true }
```

## DSL
Metaforce includes a lightweight DSL to make deployments and retrieve's easier.

```ruby
require "metaforce/dsl"
include Metaforce::DSL::Metadata

login :username => 'username', :password => 'password', :security_token => 'security token' do

  deploy File.dirname(__FILE__) do |result|
      puts "Successful deployment!"
      puts result
  end

  retrieve File.expand_path("../src/package.xml", __FILE__) |result, zip|
      puts "Successful retrieve!"
      puts result
      File.open("retrieve.zip", "wb") do |file|
        file.write(zip)
      end
  end

  retrieve File.expand_path("../src/package.xml", __FILE__), :to => "directory"
end
```

## Roadmap
This gem is far from being feature complete. Here's a list of things that still
need to be done.

* <del>Implement .retrieve for retrieving metadata.</del>
* Implement CRUD based calls <http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_crud_based_calls_intro.htm>.
* Implement some helper methods for diffing metadata.
* <del>Implement a DSL.</del>
* And some other stuff that I haven't quite thought of yet...

## Contributing
If you'd like to contribute code, please fork the repository and implement your
feature on a new branch, then send me a pull request with a detailed
description. Please provide applicable rspec specs.

## Version History
**0.3.0.alpha** (January 29, 2012)

* Ability to retrieve metadata from an organization.
* Added a DSL.

**0.2.0.alpha** (January 28, 2012)

* Gem now supports interacting with the metadata api.

**0.1.0.alpha** (January 10, 2012)

* Ability to parse and modify package.xml files easily.

## License
Copyright (C) 2012  Eric Holmes

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
