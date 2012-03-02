# Metaforce Rake Tasks
These are a set of default rake tasks that can be used for deploying/retrieving
metadata using Rake and Metaforce. The following rake tasks are provided:

* metaforce:deploy
* metaforce:retrieve
* metaforce:tests:ci

You can include the rake tasks by adding the following to your Rakefile:

```ruby
begin
  require 'metaforce'
  load 'metaforce/tasks/metaforce.rake'
rescue LoadError
  task :metaforce do
    puts "Couldn't load metaforce tasks"
  end
end
```

## metaforce.yml
Include a metaforce.yml file in the root if you'd rather not type in your
username, password and security token everytime you deploy or retrieve.

With one environment:

```yaml
---
username: user
password: password
security_token: securitytoken
test: true # defaults to false
```

With multiple environments:

```yaml
---
production:
    username: user
    password: password
    security_token: securitytoken
sandbox:
    username: user
    password: password
    security_token: securitytoken
    test: true
```

This would deploy using the `sandbox` environment:

`rake metaforce:deploy env="sandbox"`

## Continuous Integration
The `metaforce:tests:ci` task is provided to make continuous integration with
something like [Jenkins](http://jenkins-ci.org) easier.

By default, the `metaforce:tests:ci` task will use the `ci` environment in
metaforce.yml, so you should set that up before you use this task.

The task will deploy the metadata and run all tests.
