# Metaforce

[![travis-ci](https://secure.travis-ci.org/ejholmes/metaforce.png)](https://secure.travis-ci.org/ejholmes/metaforce) [![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/ejholmes/metaforce) [![Dependency Status](https://gemnasium.com/ejholmes/metaforce.png)](https://gemnasium.com/ejholmes/metaforce)

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
client = Metaforce.new :username => 'username',
  :password => 'password',
  :security_token => 'security token'
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
    options.merge!(Metaforce.login(options))
  }
end

# Reauthentication with Restforce
Metaforce.configure do |config|
  config.authentication_handler = lambda { |client, options|
    options[:session_id] = restforce_client.authenticate!.access_token
  }
end
```

#### Asynchronous Tasks

Some calls to the SOAP API's are performed asynchronously (such as deployments),
meaning the response needs to be polled for. Any call to the SOAP API's that
are performed asynchronously will return a Metaforce::Job object, which can be used to
subscribe to `on_complete` and `on_error` callbacks.

* * *

### deploy(path, options={})

Takes a path (can be a path to a directory, or a zip file), and a set of
[DeployOptions](http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_deploy.htm#deploy_options)
and returns a `Metaforce::Job::Deploy`.

```ruby
client.deploy(File.expand_path('./src'))
  .on_complete { |job| puts "Finished deploy #{job.id}!" }
  .on_error    { |job| puts "Something bad happened!" }
  .perform
#=> #<Metaforce::Job::Deploy @id='1234'>
```

* * *

### retrieve\_unpackaged(manifest, options={})

Takes a manifest (`Metaforce::Manifest` or a path to a package.xml file) and a
set of [RetrieveOptions](http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_retrieve_request.htm)
and returns a `Metaforce::Job::Retrieve`.

```ruby
manifest = Metaforce::Manifest.new(:custom_object => ['Account'])
client.retrieve_unpackaged(manifest)
  .extract_to('./tmp')
  .perform
#=> #<Metaforce::Job::Retrieve @id='1234'>
```

* * *

### create(type, metadata={})

Takes a Symbol type and a Hash of [Metadata Attributes](http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_types_list.htm)
and returns a `Metaforce::Job::CRUD`.

```ruby
client.create(:apex_page, full_name: 'Foobar', content: 'Hello World!')
  .on_complete { |job| puts "ApexPage created." }
  .perform
#=> #<Metaforce::Job::CRUD @id='1234'>
```

* * *

### update(type, current\_name metadata={})

Takes a Symbol type, the current `full_name` of the resource, and a Hash of
[Metadata Attributes](http://www.salesforce.com/us/developer/docs/api_meta/Content/meta_types_list.htm)
and returns a `Metaforce::Job::CRUD`.

```ruby
client.update(:apex_page, 'Foobar', content: 'Hello World! Some new content!')
  .on_complete { |job| puts "ApexPage updated." }
  .perform
#=> #<Metaforce::Job::CRUD @id='1234'>
```

* * *

### delete(type, \*args)

Takes a Symbol type, and the `full_name` of a resource and returns a `Metaforce::Job::CRUD`.

```ruby
client.delete(:apex_page, 'Foobar')
  .on_complete { |job| puts "ApexPage deleted." }
  .perform
#=> #<Metaforce::Job::CRUD @id='1234'>
```

* * *

### send\_email(options={})

Sends a [SingleEmailMessage](http://www.salesforce.com/us/developer/docs/api/Content/sforce_api_calls_sendemail.htm) using Salesforce.

```ruby
client.send_email(
  to_addresses: ['foo@bar.com'],
  subject: 'Hello World',
  plain_text_body: 'Hello World'
)
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
