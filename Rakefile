require "bundler/gem_tasks"

task :default => :spec

desc "Run specs"
task :spec do
  sh "bundle exec rspec spec"
end

desc "Start an irb session"
task :console do
  sh "irb -I lib -r metaforce"
end

desc "Build and publish gem on rubygems.org"
task :publish do
  sh "gem build metaforce.gemspec && gem push metaforce-*.gem"
end
