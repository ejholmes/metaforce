# Metaforce

[![Build Status](https://travis-ci.org/ejholmes/metaforce.png?branch=master)](https://travis-ci.org/ejholmes/metaforce) [![Code Climate](https://codeclimate.com/github/ejholmes/metaforce.png)](https://codeclimate.com/github/ejholmes/metaforce) [![Dependency Status](https://gemnasium.com/ejholmes/metaforce.png)](https://gemnasium.com/ejholmes/metaforce)

Metaforce is a Ruby gem for interacting with the Salesforce [Metadata](http://www.salesforce.com/us/developer/docs/api_meta/index.htm)
and [Services](http://www.salesforce.com/us/developer/docs/api/index.htm) APIs.

[Documentation](http://rubydoc.info/gems/metaforce/frames)

## Installation

Add this line to your application's Gemfile:

    gem 'metaforce'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install metaforce

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

Or you can specify the username, password and security token with environment
variables:

```bash
export SALESFORCE_USERNAME="username"
export SALESFORCE_PASSWORD="password"
export SALESFORCE_SECURITY_TOKEN="security token"
```

```ruby
client = Metaforce.new
```

#### Asynchronous Tasks

Some calls to the SOAP API's are performed asynchronously (such as deployments),
meaning the response needs to be polled for. Any call to the SOAP API's that
are performed asynchronously will return a Metaforce::Job object, which can be used to
subscribe to `on_complete` and `on_error` callbacks. The Metaforce::Job class
will poll the status of the asynchronous job in a thread until it completes or
fails.

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

If you're using Rails, check out the [metaforce-delivery\_method](https://github.com/ejholmes/metaforce-delivery_method)
gem, which allows you to use Salesforce as the delivery mechanism for sending
emails.

## Command-line

Metaforce also comes with a handy command line utility that can deploy and retrieve
code from Salesforce. It also allows you to watch a directory and deploy when
anything changes.

When you deploy, it will also run all tests and provide you with a report,
similar to rspec.

```bash
$ metaforce deploy ./src
Deploying: ./src
```

```bash
$ metaforce watch ./src
Watching: ./src
```

```bash
$ metaforce retrieve ./src
Retrieving: ./src/package.xml

$ metaforce retrieve ./src/package.xml ./other-location
Retrieving: ./src/package.xml
```

### .metaforce.yml

The metaforce command will pull it's configuration from a `.metaforce.yml`
file, if present. You can provide options for multiple environments, then use
the `-e` swtich on the command line to use an environment. See the
[examples](examples) directory for an example.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
