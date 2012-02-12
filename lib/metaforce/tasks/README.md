# Metaforce Rake Tasks
Including the metaforce rake tasks.

Gemfile:

```ruby
gem 'rake'
gem 'metaforce'
```

Rakefile

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

## Tasks

**rake metaforce:deploy**

## metaforce.yml
Include a metaforce.yml file in the root if you'd rather not type in your
username, password and security token everytime.

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

`rake metaforce:deploy env="sandbox"`

`rake metaforce:retrieve env="production" dir="production_code"`
