# Metaforce [![travis-ci](https://secure.travis-ci.org/ejholmes/metaforce.png)](https://secure.travis-ci.org/ejholmes/metaforce)

Metaforce is a Ruby gem for interacting with the Salesforce [Metadata](http://www.salesforce.com/us/developer/docs/api_meta/index.htm)
and [Services](http://www.salesforce.com/us/developer/docs/api/index.htm) APIs.

[Documentation](http://rubydoc.info/gems/metaforce/frames)

## Installation

```bash
gem install metaforce
```

## Usage

### Initialization

#### Username and Password

To initialize a new client, you call `Metaforce.new` with a hash that specifies
the `:username`, `:password`, and `:security_token`.

```ruby
client = Metaforce.new :username => 'username', :password => 'password', :security_token => 'security token'
```

#### Reauthentication

The session\_id will eventually expire. In these cases, Metaforce will invoke
the `Metaforce.configuration.authentication_handler` with two arguments: the
client and the options hash. Your authentication\_handler lambda should set
the session\_id of the options hash to a valid session\_id.


```ruby
# Default authentication_handler:
Metaforce.configure do |config|
  config.authentication_handler = lambda { |client, options|
    options.merge(Metaforce.login options)
  }
end

# Reauthentication with Restforce
Metaforce.configure do |config|
  config.authentication_handler = lambda { |client, options|
    options[:session_id] = restforce_client.authenticate!.access_token
  }
end
```

### client.deploy(path, options={})

Takes a path (can be a path to a directory, or a zip file), and a set of
[DeployOptions](http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_deploy.htm#deploy_options)
and returns a `Metaforce::Job::Deploy`.

```ruby
job = client.deploy(File.expand_path('./src'))

job.on_complete do |job|
  puts "Finished deploying #{job.id}!"
end

job.on_error do |job|
  puts "Something bad happened!"
end

job.perform
```

## Contributing

If you'd like to contribute code, please fork the repository and implement your
feature on a new branch, then send me a pull request with a detailed
description. Please provide applicable tests.

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
