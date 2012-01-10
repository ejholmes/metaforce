# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "metaforce/version"

Gem::Specification.new do |s|
  s.name        = "metaforce"
  s.version     = Metaforce::VERSION
  s.authors     = ["Eric J. Holmes"]
  s.email       = ["eric@ejholmes.net"]
  s.homepage    = ""
  s.summary     = %q{A ruby library for creating sfdc metadata files}
  s.description = %q{A ruby library for creating sfdc metadata files}

  s.rubyforge_project = "metaforce"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_dependency "nokogiri"
  s.add_dependency "savon"
end
