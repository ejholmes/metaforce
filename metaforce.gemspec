# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "metaforce/version"

Gem::Specification.new do |s|
  s.name        = "metaforce"
  s.version     = Metaforce::VERSION
  s.authors     = ["Eric J. Holmes"]
  s.email       = ["eric@ejholmes.net"]
  s.homepage    = "https://github.com/ejholmes/metaforce"
  s.summary     = %q{A Ruby gem for interacting with the Salesforce Metadata API}
  s.description = %q{A Ruby gem for interacting with the Salesforce Metadata API}

  s.rubyforge_project = "metaforce"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency "nokogiri", "~> 1.5.0"
  s.add_dependency "savon", "~> 0.9.7"
  s.add_dependency "rubyzip", "~> 0.9.5"
  s.add_dependency "term-ansicolor"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "mocha"
  s.add_development_dependency "savon_spec", "~> 0.1.6"
end
